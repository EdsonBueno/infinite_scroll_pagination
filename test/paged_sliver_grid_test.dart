import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import 'screen_size_utils.dart';

const _firstPageItemList = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
const _secondPageItemList = [
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20'
];
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
          _buildPagingControllerLoadedWithFirstPage();

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
      final pagingController = _buildPagingControllerLoadedWithTwoPages();
      pagingController.addPageRequestListener(mockPageRequestListener);

      await _pumpPagedSliverGrid(
        tester: tester,
        pagingController: pagingController,
      );

      verifyZeroInteractions(mockPageRequestListener);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.configureScreenSize(_screenSize);
      final pagingController = _buildPagingControllerLoadedWithTwoPages();
      pagingController.addPageRequestListener(mockPageRequestListener);

      await _pumpPagedSliverGrid(
        tester: tester,
        pagingController: pagingController,
      );

      await tester.scrollUntilVisible(
        find.text(
          _secondPageItemList[5],
        ),
        _itemHeight,
      );

      verify(mockPageRequestListener(3)).called(1);
    });

    group('Displays indicators as grid children when specified', () {
      testWidgets(
          'Displays new page progress indicator below the grid when '
          '[showNewPageProgressIndicatorAsGridChild] is false', (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController = _buildPagingControllerLoadedWithFirstPage();

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

        _expectWidgetFromKeyToHaveScreenWidth(customIndicatorKey, tester);
      });

      testWidgets(
          'Displays new page error indicator below the grid when '
          '[showNewPageErrorIndicatorAsGridChild] is false', (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController =
            _buildPagingControllerLoadedWithErrorOnSecondPage();

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

        _expectWidgetFromKeyToHaveScreenWidth(customIndicatorKey, tester);
      });

      testWidgets(
          'Displays no more items indicator below the grid when '
          '[showNoMoreItemsIndicatorAsGridChild] is false', (tester) async {
        tester.configureScreenSize(_screenSize);
        final pagingController = _buildCompletedPagingController();

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

        _expectWidgetFromKeyToHaveScreenWidth(customIndicatorKey, tester);
      });
    });
  });
}

void _expectWidgetFromKeyToHaveScreenWidth(Key key, WidgetTester tester) {
  final widgetFinder = find.byKey(key);
  final widgetSize = tester.getSize(widgetFinder);
  expect(widgetSize.width, _screenSize.width);
}

PagingController<int, String>
    _buildPagingControllerLoadedWithErrorOnSecondPage() =>
        PagingController<int, String>.fromValue(
          PagingState(
            nextPageKey: 2,
            itemList: _firstPageItemList,
            error: Error(),
          ),
          firstPageKey: 1,
        );

PagingController<int, String> _buildCompletedPagingController() =>
    PagingController<int, String>.fromValue(
      const PagingState(
        nextPageKey: null,
        itemList: _firstPageItemList,
      ),
      firstPageKey: 1,
    );

PagingController<int, String> _buildPagingControllerLoadedWithTwoPages() =>
    PagingController<int, String>.fromValue(
      const PagingState(
        nextPageKey: 3,
        itemList: [..._firstPageItemList, ..._secondPageItemList],
      ),
      firstPageKey: 1,
    );

PagingController<int, String> _buildPagingControllerLoadedWithFirstPage() =>
    PagingController<int, String>.fromValue(
      const PagingState(
        nextPageKey: 2,
        itemList: _firstPageItemList,
      ),
      firstPageKey: 1,
    );

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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 2,
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
