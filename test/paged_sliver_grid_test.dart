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
          PagingController<int, String>.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: _firstPageItemList,
        ),
        firstPageKey: 1,
      );

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
      final pagingController = PagingController<int, String>.fromValue(
        const PagingState(
          nextPageKey: 3,
          itemList: [..._firstPageItemList, ..._secondPageItemList],
        ),
        firstPageKey: 1,
      );
      pagingController.addPageRequestListener(mockPageRequestListener);

      await _pumpPagedSliverGrid(
        tester: tester,
        pagingController: pagingController,
      );

      verifyZeroInteractions(mockPageRequestListener);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.configureScreenSize(_screenSize);
      final pagingController = PagingController<int, String>.fromValue(
        const PagingState(
          nextPageKey: 3,
          itemList: [..._firstPageItemList, ..._secondPageItemList],
        ),
        firstPageKey: 1,
      );
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
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
