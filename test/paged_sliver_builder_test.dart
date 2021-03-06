import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/no_items_found_indicator.dart';

void main() {
  group('PagingStatus.loadingFirstPage', () {
    late PagingController pagingController;
    setUp(() {
      pagingController = PagingController(firstPageKey: 1);
    });

    testWidgets(
        'When no custom first page progress indicator is provided, '
        'a FirstPageProgressIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
      );

      // when
      await _pumpFirstPageIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      // then
      _expectOneWidgetOfType(FirstPageProgressIndicator);
    });

    testWidgets(
        'Uses the custom first page progress indicator when one is provided.',
        (tester) async {
      // given
      final customIndicatorKey = UniqueKey();
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
        firstPageProgressIndicatorBuilder: (context) => Container(
          key: customIndicatorKey,
        ),
      );

      // when
      await _pumpFirstPageIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      // then
      _expectWidgetWithKey(customIndicatorKey);
    });
  });

  group('PagingStatus.firstPageError', () {
    late PagingController pagingController;
    setUp(() {
      pagingController = PagingController.fromValue(
        PagingState(
          error: Error(),
        ),
        firstPageKey: 1,
      );
    });

    testWidgets(
        'When no custom first page error indicator is provided, '
        'a FirstPageErrorIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
      );

      // when
      await _pumpFirstPageIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      // then
      _expectOneWidgetOfType(FirstPageErrorIndicator);
    });

    testWidgets(
        'Uses the custom first page error indicator when one is provided.',
        (tester) async {
      // given
      final customIndicatorKey = UniqueKey();
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
        firstPageErrorIndicatorBuilder: (context) => Container(
          key: customIndicatorKey,
        ),
      );

      // when
      await _pumpFirstPageIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      // then
      _expectWidgetWithKey(customIndicatorKey);
    });
  });

  group('PagingStatus.noItemsFound', () {
    late PagingController pagingController;
    setUp(() {
      pagingController = PagingController.fromValue(
        const PagingState(
          itemList: [],
        ),
        firstPageKey: 1,
      );
    });

    testWidgets(
        'When no custom no items found indicator is provided, '
        'a NoItemsFoundIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
      );

      // when
      await _pumpFirstPageIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      // then
      _expectOneWidgetOfType(NoItemsFoundIndicator);
    });

    testWidgets(
        'Uses the custom no items found indicator when one is provided.',
        (tester) async {
      // given
      final customIndicatorKey = UniqueKey();
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
        noItemsFoundIndicatorBuilder: (context) => Container(
          key: customIndicatorKey,
        ),
      );

      // when
      await _pumpFirstPageIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      // then
      _expectWidgetWithKey(customIndicatorKey);
    });
  });

  group('PagingStatus.subsequentPageError', () {
    late PagingController pagingController;
    setUp(() {
      pagingController = PagingController.fromValue(
        PagingState(
          itemList: const [1, 2, 3, 4],
          nextPageKey: 3,
          error: Error(),
        ),
        firstPageKey: 1,
      );
    });

    testWidgets(
        'When no custom new page error indicator is provided, '
        'a NewPageErrorIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
      );

      // when
      await _pumpNewPageErrorIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      await tester.pump();

      // then
      _expectOneWidgetOfType(NewPageErrorIndicator);
    });

    testWidgets(
        'Uses the custom new page error indicator when one is provided.',
        (tester) async {
      // given
      final customIndicatorKey = UniqueKey();
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
        newPageErrorIndicatorBuilder: (context) => Text(
          'Error',
          key: customIndicatorKey,
        ),
      );

      // when
      await _pumpNewPageErrorIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      await tester.pump();

      // then
      _expectWidgetWithKey(customIndicatorKey);
    });
  });

  group('PagingStatus.ongoing', () {
    late PagingController pagingController;
    setUp(() {
      pagingController = PagingController.fromValue(
        const PagingState(
          itemList: [1, 2, 3, 4],
          nextPageKey: 3,
        ),
        firstPageKey: 1,
      );
    });

    testWidgets(
        'When no custom new page progress indicator is provided, '
        'a NewPageProgressIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
      );

      // when
      await _pumpNewPageProgressIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      await tester.pump();

      // then
      _expectOneWidgetOfType(NewPageProgressIndicator);
    });

    testWidgets(
        'Uses the custom new page progress indicator when one is provided.',
        (tester) async {
      // given
      final customIndicatorKey = UniqueKey();
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
        newPageProgressIndicatorBuilder: (context) => CircularProgressIndicator(
          key: customIndicatorKey,
        ),
      );

      // when
      await _pumpNewPageProgressIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      await tester.pump();

      // then
      _expectWidgetWithKey(customIndicatorKey);
    });
  });

  group('PagingStatus.completed', () {
    late PagingController pagingController;
    setUp(() {
      pagingController = PagingController.fromValue(
        const PagingState(
          itemList: [1, 2, 3, 4],
        ),
        firstPageKey: 1,
      );
    });

    testWidgets('Uses the custom no more items indicator when one is provided.',
        (tester) async {
      // given
      final customIndicatorKey = UniqueKey();
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
        noMoreItemsIndicatorBuilder: (context) => Text(
          'No more items.',
          key: customIndicatorKey,
        ),
      );

      // when
      await _pumpNoMoreItemsIndicatorTestPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      await tester.pump();

      // then
      _expectWidgetWithKey(customIndicatorKey);
    });
  });
}

Future<void> _pumpFirstPageIndicatorTestPagedSliverBuilder({
  required WidgetTester tester,
  required PagingController pagingController,
  required PagedChildBuilderDelegate builderDelegate,
}) =>
    _pumpSliver(
      sliver: PagedSliverBuilder(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        loadingListingBuilder: (_, __, ___, ____) => Container(),
        errorListingBuilder: (_, __, ___, ____) => Container(),
        completedListingBuilder: (_, __, ___, ____) => Container(),
      ),
      tester: tester,
    );

Future<void> _pumpNewPageErrorIndicatorTestPagedSliverBuilder({
  required WidgetTester tester,
  required PagingController pagingController,
  required PagedChildBuilderDelegate builderDelegate,
}) =>
    _pumpSliver(
      sliver: PagedSliverBuilder(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        loadingListingBuilder: (_, __, ___, ____) => Container(),
        errorListingBuilder: (
          context,
          __,
          ___,
          newPageErrorIndicatorBuilder,
        ) =>
            SliverToBoxAdapter(
          child: newPageErrorIndicatorBuilder(
            context,
          ),
        ),
        completedListingBuilder: (_, __, ___, ____) => Container(),
      ),
      tester: tester,
    );

Future<void> _pumpNewPageProgressIndicatorTestPagedSliverBuilder({
  required WidgetTester tester,
  required PagingController pagingController,
  required PagedChildBuilderDelegate builderDelegate,
}) =>
    _pumpSliver(
      sliver: PagedSliverBuilder(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        errorListingBuilder: (_, __, ___, ____) => Container(),
        loadingListingBuilder: (
          context,
          __,
          ___,
          newPageProgressIndicatorBuilder,
        ) =>
            SliverToBoxAdapter(
          child: newPageProgressIndicatorBuilder(
            context,
          ),
        ),
        completedListingBuilder: (_, __, ___, ____) => Container(),
      ),
      tester: tester,
    );

Future<void> _pumpNoMoreItemsIndicatorTestPagedSliverBuilder({
  required WidgetTester tester,
  required PagingController pagingController,
  required PagedChildBuilderDelegate builderDelegate,
}) =>
    _pumpSliver(
      sliver: PagedSliverBuilder(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        errorListingBuilder: (_, __, ___, ____) => Container(),
        loadingListingBuilder: (_, __, ___, ____) => Container(),
        completedListingBuilder: (
          context,
          __,
          ___,
          noMoreItemsIndicatorBuilder,
        ) =>
            SliverToBoxAdapter(
          child: noMoreItemsIndicatorBuilder?.call(
            context,
          ),
        ),
      ),
      tester: tester,
    );

Future<void> _pumpSliver({
  required Widget sliver,
  required WidgetTester tester,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              sliver,
            ],
          ),
        ),
      ),
    );

void _expectWidgetWithKey(Key key) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
}

void _expectOneWidgetOfType(Type type) {
  final finder = find.byType(type);
  expect(finder, findsOneWidget);
}
