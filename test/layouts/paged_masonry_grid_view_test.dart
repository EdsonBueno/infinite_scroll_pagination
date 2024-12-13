import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import '../utils/paging_controller_utils.dart';
import '../utils/screen_size_utils.dart';

double get _itemHeight => (screenSize.height / pageSize) * 2;

void main() {
  group('Page requests', () {
    late MockPageRequestListener mockPageRequestListener;

    setUp(() {
      mockPageRequestListener = MockPageRequestListener();
    });

    testWidgets('Requests first page only once', (tester) async {
      await _pumpPagedStaggeredGridView(
        tester: tester,
        state: TestPagingState.loadingFirstPage(),
        fetchNextPage: mockPageRequestListener.call,
      );

      verify(mockPageRequestListener()).called(1);
    });

    testWidgets(
        'Requests second page immediately if the first page isn\'t enough',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpPagedStaggeredGridView(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize ~/ 2),
        fetchNextPage: mockPageRequestListener.call,
      );

      verify(mockPageRequestListener()).called(1);
    });

    testWidgets('Doesn\'t request a page unnecessarily', (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpPagedStaggeredGridView(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize * 2),
        fetchNextPage: mockPageRequestListener.call,
      );

      verifyZeroInteractions(mockPageRequestListener);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpPagedStaggeredGridView(
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

    group('Displays indicators as grid children', () {
      testWidgets('Appends the new page progress indicator to the grid items',
          (tester) async {
        tester.applyPreferredTestScreenSize();

        final customIndicatorKey = UniqueKey();
        final customNewPageProgressIndicator = CircularProgressIndicator(
          key: customIndicatorKey,
        );

        await _pumpPagedStaggeredGridView(
          tester: tester,
          state: TestPagingState.ongoing(),
          fetchNextPage: mockPageRequestListener.call,
          newPageProgressIndicator: customNewPageProgressIndicator,
          crossAxisCount: 2,
        );

        await tester.scrollUntilVisible(
          find.byKey(customIndicatorKey),
          _itemHeight,
        );

        expectWidgetToHaveHalfOfTheScreenWidth(
          customIndicatorKey,
          tester,
        );
      });

      testWidgets('Appends the new page error indicator to the grid items',
          (tester) async {
        tester.applyPreferredTestScreenSize();

        final customIndicatorKey = UniqueKey();
        final customNewPageErrorIndicator = Text(
          'Error',
          key: customIndicatorKey,
        );

        await _pumpPagedStaggeredGridView(
          tester: tester,
          state: TestPagingState.subsequentPageError(),
          fetchNextPage: mockPageRequestListener.call,
          newPageErrorIndicator: customNewPageErrorIndicator,
          crossAxisCount: 2,
        );

        await tester.scrollUntilVisible(
          find.byKey(customIndicatorKey),
          _itemHeight,
        );

        expectWidgetToHaveHalfOfTheScreenWidth(
          customIndicatorKey,
          tester,
        );
      });

      testWidgets('Appends the no more items indicator to the grid items',
          (tester) async {
        tester.applyPreferredTestScreenSize();

        final customIndicatorKey = UniqueKey();
        final customNoMoreItemsIndicator = Text(
          'No More Items',
          key: customIndicatorKey,
        );

        await _pumpPagedStaggeredGridView(
          tester: tester,
          state: TestPagingState.completed(),
          fetchNextPage: mockPageRequestListener.call,
          noMoreItemsIndicator: customNoMoreItemsIndicator,
          crossAxisCount: 2,
        );

        await tester.scrollUntilVisible(
          find.byKey(customIndicatorKey),
          _itemHeight,
        );

        expectWidgetToHaveHalfOfTheScreenWidth(
          customIndicatorKey,
          tester,
        );
      });
    });
  });
}

Future<void> _pumpPagedStaggeredGridView({
  required WidgetTester tester,
  required PagingState<int, String> state,
  required NextPageCallback fetchNextPage,
  int crossAxisCount = 2,
  Widget? newPageProgressIndicator,
  Widget? newPageErrorIndicator,
  Widget? noMoreItemsIndicator,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedMasonryGridView.count(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<String>(
              itemBuilder: buildTestTile(_itemHeight),
              newPageProgressIndicatorBuilder: newPageProgressIndicator != null
                  ? (context) => newPageProgressIndicator
                  : null,
              newPageErrorIndicatorBuilder: newPageErrorIndicator != null
                  ? (context) => newPageErrorIndicator
                  : null,
              noMoreItemsIndicatorBuilder: noMoreItemsIndicator != null
                  ? (context) => noMoreItemsIndicator
                  : null,
            ),
            crossAxisCount: 2,
          ),
        ),
      ),
    );
