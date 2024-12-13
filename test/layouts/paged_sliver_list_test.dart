import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import '../utils/paging_controller_utils.dart';
import '../utils/screen_size_utils.dart';

double get _itemHeight => screenSize.height / pageSize;

void main() {
  group('Page requests', () {
    late MockPageRequestListener mockPageRequestListener;

    setUp(() {
      mockPageRequestListener = MockPageRequestListener();
    });

    testWidgets('Requests first page only once', (tester) async {
      await _pumpPagedSliverList(
        tester: tester,
        state: TestPagingState.loadingFirstPage(),
        fetchNextPage: mockPageRequestListener.call,
      );

      verify(mockPageRequestListener()).called(1);
    });

    testWidgets(
        'Requests second page immediately if the first page isn\'t enough',
        (tester) async {
      await _pumpPagedSliverList(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize ~/ 2),
        fetchNextPage: mockPageRequestListener.call,
      );

      verify(mockPageRequestListener()).called(1);
    });

    testWidgets('Doesn\'t request a page unnecessarily', (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpPagedSliverList(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize * 2),
        fetchNextPage: mockPageRequestListener.call,
      );

      verifyZeroInteractions(mockPageRequestListener);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpPagedSliverList(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize * 2),
        fetchNextPage: mockPageRequestListener.call,
      );

      await tester.scrollUntilVisible(
        find.text('Item ${pageSize * 2}'),
        _itemHeight,
      );

      verify(mockPageRequestListener()).called(1);
    });
  });

  testWidgets(
      'Inserts separators between items if a [separatorBuilder] is specified',
      (tester) async {
    tester.applyPreferredTestScreenSize();

    await _pumpPagedSliverList(
      tester: tester,
      state: TestPagingState.ongoing(),
      fetchNextPage: () {},
      separatorBuilder: (_, __) => const Divider(
        height: 1,
      ),
    );

    final separatorFinder = find.byType(Divider);
    expect(separatorFinder, findsNWidgets(pageSize - 1));
  });

  group('Appends indicators to the item list', () {
    testWidgets('Appends the new page progress indicator to the list items',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      final customIndicatorKey = UniqueKey();
      final customNewPageProgressIndicator = CircularProgressIndicator(
        key: customIndicatorKey,
      );

      await _pumpPagedSliverList(
        tester: tester,
        state: TestPagingState.ongoing(),
        fetchNextPage: () {},
        newPageProgressIndicator: customNewPageProgressIndicator,
      );

      await tester.scrollUntilVisible(
        find.byKey(customIndicatorKey),
        _itemHeight,
      );

      expectWidgetToHaveScreenWidth(
        customIndicatorKey,
        tester,
      );
    });

    testWidgets('Appends the new page error indicator to the list items',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      final customIndicatorKey = UniqueKey();
      final customNewPageErrorIndicator = Text(
        'Error',
        key: customIndicatorKey,
      );

      await _pumpPagedSliverList(
        tester: tester,
        state: TestPagingState.subsequentPageError(),
        fetchNextPage: () {},
        newPageErrorIndicator: customNewPageErrorIndicator,
      );

      await tester.scrollUntilVisible(
        find.byKey(customIndicatorKey),
        _itemHeight,
      );

      expectWidgetToHaveScreenWidth(
        customIndicatorKey,
        tester,
      );
    });

    testWidgets('Appends the no more items indicator to the list items',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      final customIndicatorKey = UniqueKey();
      final customNoMoreItemsIndicator = Text(
        'No More Items',
        key: customIndicatorKey,
      );

      await _pumpPagedSliverList(
        tester: tester,
        state: TestPagingState.completed(),
        fetchNextPage: () {},
        noMoreItemsIndicator: customNoMoreItemsIndicator,
      );

      await tester.scrollUntilVisible(
        find.byKey(customIndicatorKey),
        _itemHeight,
      );

      expectWidgetToHaveScreenWidth(
        customIndicatorKey,
        tester,
      );
    });
  });
}

Future<void> _pumpPagedSliverList({
  required WidgetTester tester,
  required PagingState<int, String> state,
  required NextPageCallback fetchNextPage,
  IndexedWidgetBuilder? separatorBuilder,
  Widget? newPageProgressIndicator,
  Widget? newPageErrorIndicator,
  Widget? noMoreItemsIndicator,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              if (separatorBuilder == null)
                PagedSliverList(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<String>(
                    itemBuilder: buildTestTile(_itemHeight),
                    newPageProgressIndicatorBuilder:
                        newPageProgressIndicator != null
                            ? (context) => newPageProgressIndicator
                            : null,
                    newPageErrorIndicatorBuilder: newPageErrorIndicator != null
                        ? (context) => newPageErrorIndicator
                        : null,
                    noMoreItemsIndicatorBuilder: noMoreItemsIndicator != null
                        ? (context) => noMoreItemsIndicator
                        : null,
                  ),
                )
              else
                PagedSliverList.separated(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<String>(
                    itemBuilder: buildTestTile(_itemHeight),
                    newPageProgressIndicatorBuilder:
                        newPageProgressIndicator != null
                            ? (context) => newPageProgressIndicator
                            : null,
                    newPageErrorIndicatorBuilder: newPageErrorIndicator != null
                        ? (context) => newPageErrorIndicator
                        : null,
                    noMoreItemsIndicatorBuilder: noMoreItemsIndicator != null
                        ? (context) => noMoreItemsIndicator
                        : null,
                  ),
                  separatorBuilder: separatorBuilder,
                ),
            ],
          ),
        ),
      ),
    );
