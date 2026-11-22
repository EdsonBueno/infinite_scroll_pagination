// ignore: unnecessary_import
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/paging_controller_utils.dart';

const _scrollCacheExtent = ScrollCacheExtent.pixels(123);

final _builderDelegate = PagedChildBuilderDelegate<String>(
  itemBuilder: (context, item, index) => Text(item),
);

SliverSimpleGridDelegate _gridDelegate(int childCount) =>
    const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2);

Future<void> _expectScrollCacheExtent(
  WidgetTester tester,
  Widget layout,
) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: layout)));

  expect(
    tester.widget<Viewport>(find.byType(Viewport)).scrollCacheExtent,
    same(_scrollCacheExtent),
  );
}

void main() {
  group('scrollCacheExtent reaches the Viewport', () {
    final state = TestPagingState.completed();

    final layouts = <String, Widget>{
      'PagedListView': PagedListView<int, String>(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedListView.separated': PagedListView<int, String>.separated(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        separatorBuilder: (context, index) => const SizedBox(),
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedGridView': PagedGridView<int, String>(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedMasonryGridView': PagedMasonryGridView<int, String>(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        gridDelegateBuilder: _gridDelegate,
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedMasonryGridView.count': PagedMasonryGridView<int, String>.count(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        crossAxisCount: 2,
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedMasonryGridView.extent': PagedMasonryGridView<int, String>.extent(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        maxCrossAxisExtent: 100,
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedAlignedGridView': PagedAlignedGridView<int, String>(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        gridDelegateBuilder: _gridDelegate,
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedAlignedGridView.count': PagedAlignedGridView<int, String>.count(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        crossAxisCount: 2,
        scrollCacheExtent: _scrollCacheExtent,
      ),
      'PagedAlignedGridView.extent': PagedAlignedGridView<int, String>.extent(
        state: state,
        fetchNextPage: () {},
        builderDelegate: _builderDelegate,
        maxCrossAxisExtent: 100,
        scrollCacheExtent: _scrollCacheExtent,
      ),
    };

    for (final layout in layouts.entries) {
      testWidgets('in ${layout.key}', (tester) async {
        await _expectScrollCacheExtent(tester, layout.value);
      });
    }
  });
}
