import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import '../utils/paging_controller_utils.dart';
import '../utils/screen_size_utils.dart';

double get _itemHeight => (screenSize.height / pageSize) * 2;

void main() {
  group('Page requests', () {
    late MockFetchPageRequest mockFetchNextPage;

    setUp(() {
      mockFetchNextPage = MockFetchPageRequest();
    });

    testWidgets('Requests first page only once', (tester) async {
      final state = TestPagingState.loadingFirstPage();

      await _pumpPagedGridView(
        tester: tester,
        state: state,
        fetchNextPage: mockFetchNextPage.call,
      );

      verify(mockFetchNextPage()).called(1);
    });

    testWidgets(
        'Requests second page immediately if the first page isn\'t enough',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      final state = TestPagingState.ongoing(n: pageSize ~/ 2);

      await _pumpPagedGridView(
        tester: tester,
        state: state,
        fetchNextPage: mockFetchNextPage.call,
      );

      verify(mockFetchNextPage()).called(1);
    });

    testWidgets('Doesn\'t request a page unnecessarily', (tester) async {
      tester.applyPreferredTestScreenSize();

      final state = TestPagingState.ongoing(n: pageSize * 2);

      await _pumpPagedGridView(
        tester: tester,
        state: state,
        fetchNextPage: () => Completer<void>().future,
      );

      verifyZeroInteractions(mockFetchNextPage);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.applyPreferredTestScreenSize();

      final state = TestPagingState.ongoing(n: pageSize * 2);

      await _pumpPagedGridView(
        tester: tester,
        state: state,
        fetchNextPage: mockFetchNextPage.call,
      );

      await tester.scrollUntilVisible(
        find.text('Item ${pageSize * 2}'),
        _itemHeight,
      );

      verify(mockFetchNextPage()).called(1);
    });

    group('Displays indicators as grid children', () {
      testWidgets('Appends the new page progress indicator to the grid items',
          (tester) async {
        tester.applyPreferredTestScreenSize();

        final state = TestPagingState.ongoing();

        final customIndicatorKey = UniqueKey();
        final customNewPageProgressIndicator = CircularProgressIndicator(
          key: customIndicatorKey,
        );

        await _pumpPagedGridView(
          tester: tester,
          state: state,
          fetchNextPage: () => Completer<void>().future,
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

        final state = TestPagingState.subsequentPageError();

        final customIndicatorKey = UniqueKey();
        final customNewPageErrorIndicator = Text(
          'Error',
          key: customIndicatorKey,
        );

        await _pumpPagedGridView(
          tester: tester,
          state: state,
          fetchNextPage: () => Completer<void>().future,
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

        final state = TestPagingState.completed();

        final customIndicatorKey = UniqueKey();
        final customNoMoreItemsIndicator = Text(
          'No More Items',
          key: customIndicatorKey,
        );

        await _pumpPagedGridView(
          tester: tester,
          state: state,
          fetchNextPage: () => Completer<void>().future,
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

    group('Displays indicators below the grid when specified', () {
      testWidgets(
          'Displays new page progress indicator below the grid when '
          '[showNewPageProgressIndicatorAsGridChild] is false', (tester) async {
        tester.applyPreferredTestScreenSize();

        final state = TestPagingState.ongoing();

        final customIndicatorKey = UniqueKey();
        final customNewPageProgressIndicator = CircularProgressIndicator(
          key: customIndicatorKey,
        );

        await _pumpPagedGridView(
          tester: tester,
          state: state,
          fetchNextPage: () => Completer<void>().future,
          newPageProgressIndicator: customNewPageProgressIndicator,
          showNewPageProgressIndicatorAsGridChild: false,
        );

        expectWidgetToHaveScreenWidth(
          customIndicatorKey,
          tester,
        );
      });

      testWidgets(
          'Displays new page error indicator below the grid when '
          '[showNewPageErrorIndicatorAsGridChild] is false', (tester) async {
        tester.applyPreferredTestScreenSize();

        final state = TestPagingState.subsequentPageError();

        final customIndicatorKey = UniqueKey();
        final customNewPageErrorIndicator = Text(
          'Error',
          key: customIndicatorKey,
        );

        await _pumpPagedGridView(
          tester: tester,
          state: state,
          fetchNextPage: () => Completer<void>().future,
          newPageErrorIndicator: customNewPageErrorIndicator,
          showNewPageErrorIndicatorAsGridChild: false,
        );

        expectWidgetToHaveScreenWidth(
          customIndicatorKey,
          tester,
        );
      });

      testWidgets(
          'Displays no more items indicator below the grid when '
          '[showNoMoreItemsIndicatorAsGridChild] is false', (tester) async {
        tester.applyPreferredTestScreenSize();

        final state = TestPagingState.completed();

        final customIndicatorKey = UniqueKey();
        final customNoMoreItemsIndicator = Text(
          'No More Items',
          key: customIndicatorKey,
        );

        await _pumpPagedGridView(
          tester: tester,
          state: state,
          fetchNextPage: () => Completer<void>().future,
          noMoreItemsIndicator: customNoMoreItemsIndicator,
          showNoMoreItemsIndicatorAsGridChild: false,
        );

        expectWidgetToHaveScreenWidth(
          customIndicatorKey,
          tester,
        );
      });
    });
  });
}

class MockFetchPageRequest extends Mock {
  void call();
}

Future<void> _pumpPagedGridView({
  required WidgetTester tester,
  required PagingState<int, String> state,
  required NextPageCallback fetchNextPage,
  int crossAxisCount = 2,
  Widget? newPageProgressIndicator,
  Widget? newPageErrorIndicator,
  Widget? noMoreItemsIndicator,
  bool showNewPageProgressIndicatorAsGridChild = true,
  bool showNewPageErrorIndicatorAsGridChild = true,
  bool showNoMoreItemsIndicatorAsGridChild = true,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedGridView(
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              crossAxisCount: crossAxisCount,
            ),
            showNewPageProgressIndicatorAsGridChild:
                showNewPageProgressIndicatorAsGridChild,
            showNewPageErrorIndicatorAsGridChild:
                showNewPageErrorIndicatorAsGridChild,
            showNoMoreItemsIndicatorAsGridChild:
                showNoMoreItemsIndicatorAsGridChild,
          ),
        ),
      ),
    );
