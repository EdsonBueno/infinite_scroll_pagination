import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/paging_controller_utils.dart';

final _builderDelegate = PagedChildBuilderDelegate<String>(
  itemBuilder: (context, item, index) => Text(item),
);

Future<void> _expectHitTestBehavior(WidgetTester tester, Widget layout) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: layout)));

  expect(
    tester.widget<Scrollable>(find.byType(Scrollable)).hitTestBehavior,
    HitTestBehavior.translucent,
  );
}

void main() {
  group('hitTestBehavior reaches the Scrollable', () {
    testWidgets('in PagedListView', (tester) async {
      await _expectHitTestBehavior(
        tester,
        PagedListView<int, String>(
          state: TestPagingState.completed(),
          fetchNextPage: () {},
          builderDelegate: _builderDelegate,
          hitTestBehavior: HitTestBehavior.translucent,
        ),
      );
    });

    testWidgets('in PagedGridView', (tester) async {
      await _expectHitTestBehavior(
        tester,
        PagedGridView<int, String>(
          state: TestPagingState.completed(),
          fetchNextPage: () {},
          builderDelegate: _builderDelegate,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          hitTestBehavior: HitTestBehavior.translucent,
        ),
      );
    });

    testWidgets('in PagedMasonryGridView', (tester) async {
      await _expectHitTestBehavior(
        tester,
        PagedMasonryGridView<int, String>.count(
          state: TestPagingState.completed(),
          fetchNextPage: () {},
          builderDelegate: _builderDelegate,
          crossAxisCount: 2,
          hitTestBehavior: HitTestBehavior.translucent,
        ),
      );
    });

    testWidgets('in PagedAlignedGridView', (tester) async {
      await _expectHitTestBehavior(
        tester,
        PagedAlignedGridView<int, String>.count(
          state: TestPagingState.completed(),
          fetchNextPage: () {},
          builderDelegate: _builderDelegate,
          crossAxisCount: 2,
          hitTestBehavior: HitTestBehavior.translucent,
        ),
      );
    });

    testWidgets('in PagedPageView', (tester) async {
      await _expectHitTestBehavior(
        tester,
        PagedPageView<int, String>(
          state: TestPagingState.completed(),
          fetchNextPage: () {},
          builderDelegate: _builderDelegate,
          hitTestBehavior: HitTestBehavior.translucent,
        ),
      );
    });
  });
}
