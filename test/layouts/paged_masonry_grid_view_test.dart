import 'package:material_ui/material_ui.dart';
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
      },
    );

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
      testWidgets('Appends the new page progress indicator to the grid items', (
        tester,
      ) async {
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

        expectWidgetToHaveHalfOfTheScreenWidth(customIndicatorKey, tester);
      });

      testWidgets('Appends the new page error indicator to the grid items', (
        tester,
      ) async {
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

        expectWidgetToHaveHalfOfTheScreenWidth(customIndicatorKey, tester);
      });

      testWidgets('Appends the no more items indicator to the grid items', (
        tester,
      ) async {
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

        expectWidgetToHaveHalfOfTheScreenWidth(customIndicatorKey, tester);
      });
    });

    testWidgets('Does not tick an offstage new page progress indicator when '
        '[showNewPageProgressIndicatorAsGridChild] is false', (tester) async {
      tester.applyPreferredTestScreenSize();

      final customIndicatorKey = UniqueKey();
      final customNewPageProgressIndicator = CircularProgressIndicator(
        key: customIndicatorKey,
      );

      await _pumpPagedStaggeredGridView(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize * 2),
        fetchNextPage: mockPageRequestListener.call,
        newPageProgressIndicator: customNewPageProgressIndicator,
        showNewPageProgressIndicatorAsGridChild: false,
      );
      await tester.pump();

      expect(find.byKey(customIndicatorKey), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);

      await tester.scrollUntilVisible(
        find.byKey(customIndicatorKey),
        _itemHeight,
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.binding.transientCallbackCount, greaterThan(0));
      expectWidgetToHaveScreenWidth(customIndicatorKey, tester);
    });

    testWidgets('Reaches the no more items indicator below the grid '
        'when [cacheExtent] is 0', (tester) async {
      tester.applyPreferredTestScreenSize();

      final customIndicatorKey = UniqueKey();

      await _pumpPagedStaggeredGridView(
        tester: tester,
        state: TestPagingState.completed(n: pageSize * 2),
        fetchNextPage: mockPageRequestListener.call,
        noMoreItemsIndicator: SizedBox(key: customIndicatorKey, height: 50),
        showNoMoreItemsIndicatorAsGridChild: false,
        cacheExtent: 0,
      );

      await tester.scrollUntilVisible(
        find.byKey(customIndicatorKey),
        _itemHeight,
      );

      expect(find.byKey(customIndicatorKey), findsOneWidget);
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
  bool showNewPageProgressIndicatorAsGridChild = true,
  bool showNoMoreItemsIndicatorAsGridChild = true,
  double? cacheExtent,
}) => tester.pumpWidget(
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
        showNewPageProgressIndicatorAsGridChild:
            showNewPageProgressIndicatorAsGridChild,
        showNoMoreItemsIndicatorAsGridChild:
            showNoMoreItemsIndicatorAsGridChild,
        cacheExtent: cacheExtent,
      ),
    ),
  ),
);
