import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import 'utils/paging_controller_utils.dart';
import 'utils/screen_size_utils.dart';

const _pageSize = 10;
const _screenSize = Size(200, 500);

double get _itemHeight => (_screenSize.height / _pageSize) * 2;

void main() {
  group('Page request tests', () {
    late MockPageRequestListener mockPageRequestListener;

    setUp(() {
      mockPageRequestListener = MockPageRequestListener();
    });

    testWidgets('Requests first page only once', (tester) async {
      final pagingController = PagingController<int, String>(
        firstPageKey: 1,
      );

      pagingController.addPageRequestListener(mockPageRequestListener);

      await _pumpPagedSliverGrid(
        tester: tester,
        pagingController: pagingController,
      );

      verify(mockPageRequestListener(1)).called(1);
    });

    testWidgets(
        'Requests second page immediately if the first page isn\'t enough',
        (tester) async {
      tester.configureScreenSize(_screenSize);
      final controllerLoadedWithFirstPage =
          buildPagingControllerLoadedWithFirstPage();

      controllerLoadedWithFirstPage.addPageRequestListener(
        mockPageRequestListener,
      );

      await _pumpPagedSliverGrid(
        tester: tester,
        pagingController: controllerLoadedWithFirstPage,
      );

      verify(mockPageRequestListener(2)).called(1);
    });

    testWidgets('Doesn\'t request a page unnecessarily', (tester) async {
      tester.configureScreenSize(_screenSize);
      final pagingController = buildPagingControllerLoadedWithTwoPages();
      pagingController.addPageRequestListener(mockPageRequestListener);

      await _pumpPagedSliverGrid(
        tester: tester,
        pagingController: pagingController,
      );

      verifyZeroInteractions(mockPageRequestListener);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.configureScreenSize(_screenSize);
      final pagingController = buildPagingControllerLoadedWithTwoPages();
      pagingController.addPageRequestListener(mockPageRequestListener);

      await _pumpPagedSliverGrid(
        tester: tester,
        pagingController: pagingController,
      );

      await tester.scrollUntilVisible(
        find.text(
          secondPageItemList[5],
        ),
        _itemHeight,
      );

      verify(mockPageRequestListener(3)).called(1);
    });

    group('Displays indicators as grid children', () {
      testWidgets('Appends the new page progress indicator to the grid items',
          (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController = buildPagingControllerLoadedWithFirstPage();

        final customIndicatorKey = UniqueKey();
        final customNewPageProgressIndicator = CircularProgressIndicator(
          key: customIndicatorKey,
        );

        await _pumpPagedSliverGrid(
          tester: tester,
          pagingController: pagingController,
          newPageProgressIndicator: customNewPageProgressIndicator,
          crossAxisCount: 2,
        );

        await tester.scrollUntilVisible(
          find.byKey(customIndicatorKey),
          _itemHeight,
        );

        expectWidgetFromKeyToHaveHalfOfTheScreenWidth(
          customIndicatorKey,
          tester,
          _screenSize.width,
        );
      });

      testWidgets('Appends the new page error indicator to the grid items',
          (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController =
            buildPagingControllerLoadedWithErrorOnSecondPage();

        final customIndicatorKey = UniqueKey();
        final customNewPageErrorIndicator = Text(
          'Error',
          key: customIndicatorKey,
        );

        await _pumpPagedSliverGrid(
          tester: tester,
          pagingController: pagingController,
          newPageErrorIndicator: customNewPageErrorIndicator,
          crossAxisCount: 2,
        );

        await tester.scrollUntilVisible(
          find.byKey(customIndicatorKey),
          _itemHeight,
        );

        expectWidgetFromKeyToHaveHalfOfTheScreenWidth(
          customIndicatorKey,
          tester,
          _screenSize.width,
        );
      });

      testWidgets('Appends the no more items indicator to the grid items',
          (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController = buildCompletedPagingController();

        final customIndicatorKey = UniqueKey();
        final customNoMoreItemsIndicator = Text(
          'No More Items',
          key: customIndicatorKey,
        );

        await _pumpPagedSliverGrid(
          tester: tester,
          pagingController: pagingController,
          noMoreItemsIndicator: customNoMoreItemsIndicator,
          crossAxisCount: 2,
        );

        await tester.scrollUntilVisible(
          find.byKey(customIndicatorKey),
          _itemHeight,
        );

        expectWidgetFromKeyToHaveHalfOfTheScreenWidth(
          customIndicatorKey,
          tester,
          _screenSize.width,
        );
      });
    });

    group('Displays indicators below the grid when specified', () {
      testWidgets(
          'Displays new page progress indicator below the grid when '
          '[showNewPageProgressIndicatorAsGridChild] is false', (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController = buildPagingControllerLoadedWithFirstPage();

        final customIndicatorKey = UniqueKey();
        final customNewPageProgressIndicator = CircularProgressIndicator(
          key: customIndicatorKey,
        );

        await _pumpPagedSliverGrid(
          tester: tester,
          pagingController: pagingController,
          newPageProgressIndicator: customNewPageProgressIndicator,
          showNewPageProgressIndicatorAsGridChild: false,
        );

        expectWidgetFromKeyToHaveScreenWidth(
          customIndicatorKey,
          tester,
          _screenSize.width,
        );
      });

      testWidgets(
          'Displays new page error indicator below the grid when '
          '[showNewPageErrorIndicatorAsGridChild] is false', (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController =
            buildPagingControllerLoadedWithErrorOnSecondPage();

        final customIndicatorKey = UniqueKey();
        final customNewPageErrorIndicator = Text(
          'Error',
          key: customIndicatorKey,
        );

        await _pumpPagedSliverGrid(
          tester: tester,
          pagingController: pagingController,
          newPageErrorIndicator: customNewPageErrorIndicator,
          showNewPageErrorIndicatorAsGridChild: false,
        );

        expectWidgetFromKeyToHaveScreenWidth(
          customIndicatorKey,
          tester,
          _screenSize.width,
        );
      });

      testWidgets(
          'Displays no more items indicator below the grid when '
          '[showNoMoreItemsIndicatorAsGridChild] is false', (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController = buildCompletedPagingController();

        final customIndicatorKey = UniqueKey();
        final customNoMoreItemsIndicator = Text(
          'No More Items',
          key: customIndicatorKey,
        );

        await _pumpPagedSliverGrid(
          tester: tester,
          pagingController: pagingController,
          noMoreItemsIndicator: customNoMoreItemsIndicator,
          showNoMoreItemsIndicatorAsGridChild: false,
        );

        expectWidgetFromKeyToHaveScreenWidth(
          customIndicatorKey,
          tester,
          _screenSize.width,
        );
      });
    });
  });
}

Widget _buildItem(
  BuildContext context,
  String item,
  int index,
) =>
    SizedBox(
      height: _itemHeight,
      child: Text(
        item,
      ),
    );

class MockPageRequestListener extends Mock {
  void call(int pageKey);
}

Future<void> _pumpPagedSliverGrid({
  required WidgetTester tester,
  required PagingController<int, String> pagingController,
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
              PagedSliverGrid(
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<String>(
                  itemBuilder: _buildItem,
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
              )
            ],
          ),
        ),
      ),
    );
