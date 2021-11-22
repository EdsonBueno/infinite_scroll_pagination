import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliver_tools/sliver_tools.dart';

void main() {
  group('Animated transitions', () {
    testWidgets(
        'Wraps the layout in a SliverAnimatedSwitcher if '
        'the PagedChildBuilderDelegate.animateTransitions is true',
        (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate(
        itemBuilder: (_, __, ___) => Container(),
        animateTransitions: true,
      );

      // when
      await _pumpPagedSliverLayoutBuilder(
        tester: tester,
        builderDelegate: builderDelegate,
      );

      // then
      final finder = find.byType(SliverAnimatedSwitcher);
      expect(finder, findsOneWidget);
    });

    testWidgets(
        'Doesn\'t wrap the layout in a SliverAnimatedSwitcher if '
        'the PagedChildBuilderDelegate.animateTransitions is false',
        (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate(
        itemBuilder: (_, __, ___) => Container(),
        animateTransitions: false,
      );

      // when
      await _pumpPagedSliverLayoutBuilder(
        tester: tester,
        builderDelegate: builderDelegate,
      );

      // then
      final finder = find.byType(SliverAnimatedSwitcher);
      expect(finder, findsNothing);
    });
  });

  group('Shrink wrap first page indicators', () {
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
      await _pumpPagedSliverLayoutBuilder(
        tester: tester,
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
      await _pumpPagedSliverLayoutBuilder(
        tester: tester,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: true,
      );

      // then
      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.height, indicatorHeight);
    });
  });
}

Future<void> _pumpPagedSliverLayoutBuilder({
  required WidgetTester tester,
  required PagedChildBuilderDelegate builderDelegate,
  bool shrinkWrapFirstPageIndicators = false,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              PagedSliverLayoutBuilder(
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                pagingController: PagingController(
                  firstPageKey: 1,
                ),
                builderDelegate: builderDelegate,
                errorListingBuilder: (
                  context,
                  __,
                  ___,
                  newPageErrorIndicatorBuilder,
                ) =>
                    newPageErrorIndicatorBuilder(
                  context,
                ),
                loadingListingBuilder: (
                  context,
                  __,
                  ___,
                  newPageProgressIndicatorBuilder,
                ) =>
                    newPageProgressIndicatorBuilder(
                  context,
                ),
                completedListingBuilder: (
                  context,
                  __,
                  ___,
                  noMoreItemsIndicatorBuilder,
                ) =>
                    noMoreItemsIndicatorBuilder != null
                        ? noMoreItemsIndicatorBuilder(context)
                        : Container(),
              ),
            ],
          ),
        ),
      ),
    );
