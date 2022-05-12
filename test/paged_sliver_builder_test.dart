import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/no_items_found_indicator.dart';

import 'utils/paging_controller_utils.dart';

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
      await _pumpPagedSliverBuilder(
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
      await _pumpPagedSliverBuilder(
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
      pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.errorOnFirstPage,
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
      await _pumpPagedSliverBuilder(
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
      await _pumpPagedSliverBuilder(
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
      pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.noItemsFound,
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
      await _pumpPagedSliverBuilder(
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
      await _pumpPagedSliverBuilder(
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
      pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.errorOnSecondPage,
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
      await _pumpPagedSliverBuilder(
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
      await _pumpPagedSliverBuilder(
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
      pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithTwoPages,
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
      await _pumpPagedSliverBuilder(
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
      await _pumpPagedSliverBuilder(
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
      pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.completedWithOnePage,
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
      await _pumpPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      await tester.pump();

      // then
      _expectWidgetWithKey(customIndicatorKey);
    });
  });

  group('First page indicators\' height', () {
    final pagingController = PagingController(firstPageKey: 1);
    const indicatorHeight = 100.0;
    late Key indicatorKey;
    late Widget progressIndicator;
    late PagedChildBuilderDelegate builderDelegate;
    late Finder indicatorFinder;

    setUp(() {
      indicatorKey = UniqueKey();
      progressIndicator = SizedBox(
        height: indicatorHeight,
        key: indicatorKey,
      );
      indicatorFinder = find.byKey(indicatorKey);

      builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, __, ___) => Container(),
        firstPageProgressIndicatorBuilder: (_) => progressIndicator,
      );
    });

    testWidgets(
        'By default, first page indicators are expanded to fill the '
        'remaining space', (tester) async {
      // when
      await _pumpPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: false,
      );

      // then
      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.height, isNot(indicatorHeight));
    });

    testWidgets(
        'Setting [shrinkWrapFirstPageIndicators] to true '
        'preserves the indicator height', (tester) async {
      // when
      await _pumpPagedSliverBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: true,
      );

      // then
      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.height, indicatorHeight);
    });
  });
}

void _expectWidgetWithKey(Key key) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
}

void _expectOneWidgetOfType(Type type) {
  final finder = find.byType(type);
  expect(finder, findsOneWidget);
}

Future<void> _pumpPagedSliverBuilder({
  required WidgetTester tester,
  required PagingController pagingController,
  required PagedChildBuilderDelegate builderDelegate,
  bool shrinkWrapFirstPageIndicators = false,
}) =>
    _pumpSliver(
      sliver: PagedSliverBuilder(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
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
