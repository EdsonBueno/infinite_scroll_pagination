import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import 'utils/screen_size_utils.dart';

const _firstPageItemList = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
const _pageSize = 10;
const _screenSize = Size(200, 500);

double get _itemHeight => _screenSize.height / _pageSize;

void main() {
  testWidgets(
      'Inserts separators between items if a [separatorBuilder] is specified',
      (tester) async {
    final controllerLoadedWithFirstPage =
        PagingController<int, String>.fromValue(
      const PagingState(
        nextPageKey: 2,
        itemList: _firstPageItemList,
      ),
      firstPageKey: 1,
    );
    tester.applyPreferredTestScreenSize();

    await _pumpPagedListView(
      tester: tester,
      pagingController: controllerLoadedWithFirstPage,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
      ),
    );

    final separatorFinder = find.byType(Divider);
    expect(separatorFinder, findsNWidgets(_pageSize - 1));
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

Future<void> _pumpPagedListView({
  required WidgetTester tester,
  required PagingController<int, String> pagingController,
  IndexedWidgetBuilder? separatorBuilder,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: separatorBuilder == null
              ? PagedListView(
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<String>(
                    itemBuilder: _buildItem,
                  ),
                )
              : PagedListView.separated(
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<String>(
                    itemBuilder: _buildItem,
                  ),
                  separatorBuilder: separatorBuilder,
                ),
        ),
      ),
    );
