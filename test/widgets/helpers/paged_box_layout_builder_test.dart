import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  testWidgets(
      'Wraps the layout in an AnimatedSwitcher if '
      'the PagedChildBuilderDelegate.animateTransitions is true',
      (tester) async {
    // given
    final builderDelegate = PagedChildBuilderDelegate(
      itemBuilder: (_, __, ___) => Container(),
      animateTransitions: true,
    );

    // when
    await _pumpPagedBoxLayoutBuilder(
      tester: tester,
      builderDelegate: builderDelegate,
    );

    // then
    final finder = find.byType(AnimatedSwitcher);
    expect(finder, findsOneWidget);
  });

  testWidgets(
      'Doesn\'t wrap the layout in an AnimatedSwitcher if '
      'the PagedChildBuilderDelegate.animateTransitions is false',
      (tester) async {
    // given
    final builderDelegate = PagedChildBuilderDelegate(
      itemBuilder: (_, __, ___) => Container(),
      animateTransitions: false,
    );

    // when
    await _pumpPagedBoxLayoutBuilder(
      tester: tester,
      builderDelegate: builderDelegate,
    );

    // then
    final finder = find.byType(AnimatedSwitcher);
    expect(finder, findsNothing);
  });
}

Future<void> _pumpPagedBoxLayoutBuilder({
  required WidgetTester tester,
  required PagedChildBuilderDelegate builderDelegate,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedBoxLayoutBuilder(
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
        ),
      ),
    );
