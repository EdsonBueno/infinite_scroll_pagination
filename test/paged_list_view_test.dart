import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'utils/paging_controller_utils.dart';
import 'utils/screen_size_utils.dart';

double get _itemHeight => screenSize.height / pageSize;

void main() {
  testWidgets(
      'Inserts separators between items if [separatorBuilder] is specified',
      (tester) async {
    final controllerLoadedWithFirstPage =
        buildPagingControllerWithPopulatedState(
      PopulatedStateOption.ongoingWithOnePage,
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
    expect(separatorFinder, findsNWidgets(pageSize - 1));
  });
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
