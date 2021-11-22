import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_sliver_grid_builder.dart';

import '../../utils/paging_controller_utils.dart';
import '../../utils/screen_size_utils.dart';

void main() {
  group('Displays indicators as grid children', () {
    testWidgets('Appends the new page progress indicator to the grid items',
        (tester) async {
      tester.applyPreferredTestScreenSize();

      final pagingController = PagingController.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.ongoingWithOnePage,
        ),
        firstPageKey: 1,
      );

      final customIndicatorKey = UniqueKey();
      final customNewPageProgressIndicator = CircularProgressIndicator(
        key: customIndicatorKey,
      );

      await _pumpPagedSliverGridBuilder(
        tester: tester,
        pagingController: pagingController,
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

      final pagingController = PagingController.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.errorOnSecondPage,
        ),
        firstPageKey: 1,
      );

      final customIndicatorKey = UniqueKey();
      final customNewPageErrorIndicator = Text(
        'Error',
        key: customIndicatorKey,
      );

      await _pumpPagedSliverGridBuilder(
        tester: tester,
        pagingController: pagingController,
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

      final pagingController = PagingController.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.completedWithOnePage,
        ),
        firstPageKey: 1,
      );

      final customIndicatorKey = UniqueKey();
      final customNoMoreItemsIndicator = Text(
        'No More Items',
        key: customIndicatorKey,
      );

      await _pumpPagedSliverGridBuilder(
        tester: tester,
        pagingController: pagingController,
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

      final pagingController = PagingController.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.ongoingWithOnePage,
        ),
        firstPageKey: 1,
      );

      final customIndicatorKey = UniqueKey();
      final customNewPageProgressIndicator = CircularProgressIndicator(
        key: customIndicatorKey,
      );

      await _pumpPagedSliverGridBuilder(
        tester: tester,
        pagingController: pagingController,
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

      final pagingController = PagingController.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.errorOnSecondPage,
        ),
        firstPageKey: 1,
      );

      final customIndicatorKey = UniqueKey();
      final customNewPageErrorIndicator = Text(
        'Error',
        key: customIndicatorKey,
      );

      await _pumpPagedSliverGridBuilder(
        tester: tester,
        pagingController: pagingController,
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

      final pagingController = PagingController.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.completedWithOnePage,
        ),
        firstPageKey: 1,
      );

      final customIndicatorKey = UniqueKey();
      final customNoMoreItemsIndicator = Text(
        'No More Items',
        key: customIndicatorKey,
      );

      await _pumpPagedSliverGridBuilder(
        tester: tester,
        pagingController: pagingController,
        noMoreItemsIndicator: customNoMoreItemsIndicator,
        showNoMoreItemsIndicatorAsGridChild: false,
      );

      expectWidgetToHaveScreenWidth(
        customIndicatorKey,
        tester,
      );
    });
  });
}

double get _itemHeight => (screenSize.height / pageSize) * 2;

Future<void> _pumpPagedSliverGridBuilder({
  required WidgetTester tester,
  required PagingController pagingController,
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
          body: CustomScrollView(
            slivers: [
              PagedSliverGridBuilder(
                pagingController: pagingController,
                builder: (_, delegate) => SliverGrid(
                  delegate: delegate,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    crossAxisCount: crossAxisCount,
                  ),
                ),
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (_, __, ___) => SizedBox(
                    height: _itemHeight,
                  ),
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
                showNewPageProgressIndicatorAsGridChild:
                    showNewPageProgressIndicatorAsGridChild,
                showNewPageErrorIndicatorAsGridChild:
                    showNewPageErrorIndicatorAsGridChild,
                showNoMoreItemsIndicatorAsGridChild:
                    showNoMoreItemsIndicatorAsGridChild,
              ),
            ],
          ),
        ),
      ),
    );
