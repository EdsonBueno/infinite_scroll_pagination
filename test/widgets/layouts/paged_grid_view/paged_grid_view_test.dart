import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../utils/paging_controller_utils.dart';
import '../../../utils/screen_size_utils.dart';

void main() {
  group('first page indicators', () {
    testWidgets('loading first page', (tester) async {
      final pagingController = PagingController<int, String>(
        firstPageKey: 1,
      );

      await tester.goldenTest(
        pagingController: pagingController,
        goldenName: 'loading_first_page',
      );
    });

    testWidgets('error on first page', (tester) async {
      final pagingController = PagingController<int, String>.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.errorOnFirstPage,
        ),
        firstPageKey: 1,
      );

      await tester.goldenTest(
        pagingController: pagingController,
        goldenName: 'error_on_first_page',
      );
    });

    testWidgets('no items found', (tester) async {
      final pagingController = PagingController<int, String>.fromValue(
        buildPagingStateWithPopulatedState(
          PopulatedStateOption.noItemsFound,
        ),
        firstPageKey: 1,
      );

      await tester.goldenTest(
        pagingController: pagingController,
        goldenName: 'no_items_found',
      );
    });
  });

  group('populated states', () {
    group('display indicators as grid children', () {
      testWidgets('subsequent page error', (tester) async {
        final pagingController = PagingController<int, String>.fromValue(
          buildPagingStateWithPopulatedState(
            PopulatedStateOption.errorOnSecondPage,
          ),
          firstPageKey: 1,
        );

        await tester.goldenTest(
          pagingController: pagingController,
          goldenName: 'subsequent_page_error',
        );
      });
      testWidgets('ongoing', (tester) async {});
      testWidgets('completed', (tester) async {});
    });
    group('display indicators below the grid', () {
      testWidgets('subsequent page error', (tester) async {});
      testWidgets('ongoing', (tester) async {});
      testWidgets('completed', (tester) async {});
    });
  });
}

extension on WidgetTester {
  Future<void> goldenTest({
    required PagingController<int, String> pagingController,
    required String goldenName,
  }) async {
    applyPreferredTestScreenSize();
    final gridKey = UniqueKey();

    await pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedGridView<int, String>(
            key: gridKey,
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<String>(
              itemBuilder: (_, item, ___) => Text(item),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
          ),
        ),
      ),
    );
    final gridFinder = find.byKey(gridKey);

    await drag(
      gridFinder,
      Offset(
        0,
        screenSize.height * -1,
      ),
    );

    await pump();

    await expectLater(
      gridFinder,
      matchesGoldenFile('goldens/$goldenName.png'),
    );
  }
}
