import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/no_items_found_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/mocks.dart';
import '../../utils/paging_controller_utils.dart';

void main() {
  late PagingController pagingController;

  setUp(() {
    pagingController = MockPagingController();
  });

  group('Uses the appropriate indicators', () {
    group('When the status is PagingStatus.loadingFirstPage', () {
      setUp(() {
        when(() => pagingController.value).thenReturn(
          const PagingState(),
        );
      });

      testWidgets(
          'Uses a FirstPageProgressIndicator when no custom first page '
          'progress indicator is provided.', (tester) async {
        // given
        final builderDelegate = PagedChildBuilderDelegate<int>(
          itemBuilder: (_, __, ___) => Container(),
        );

        // when
        await _pumpPagedLayoutBuilder(
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
        await _pumpPagedLayoutBuilder(
          tester: tester,
          pagingController: pagingController,
          builderDelegate: builderDelegate,
        );

        // then
        _expectWidgetWithKey(customIndicatorKey);
      });
    });

    group('When the status is PagingStatus.firstPageError', () {
      setUp(() {
        when(() => pagingController.value).thenReturn(
          buildPagingStateWithPopulatedState(
            PopulatedStateOption.errorOnFirstPage,
          ),
        );
      });

      testWidgets(
          'Uses a FirstPageErrorIndicator when no custom first page error '
          'indicator is provided.', (tester) async {
        // given
        final builderDelegate = PagedChildBuilderDelegate<int>(
          itemBuilder: (_, __, ___) => Container(),
        );

        // when
        await _pumpPagedLayoutBuilder(
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
        await _pumpPagedLayoutBuilder(
          tester: tester,
          pagingController: pagingController,
          builderDelegate: builderDelegate,
        );

        // then
        _expectWidgetWithKey(customIndicatorKey);
      });
    });

    group('When the status is PagingStatus.noItemsFound', () {
      setUp(() {
        when(() => pagingController.value).thenReturn(
          buildPagingStateWithPopulatedState(
            PopulatedStateOption.noItemsFound,
          ),
        );
      });

      testWidgets(
          'Uses a NoItemsFoundIndicator when no custom no items found '
          'indicator is provided.', (tester) async {
        // given
        final builderDelegate = PagedChildBuilderDelegate<int>(
          itemBuilder: (_, __, ___) => Container(),
        );

        // when
        await _pumpPagedLayoutBuilder(
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
        await _pumpPagedLayoutBuilder(
          tester: tester,
          pagingController: pagingController,
          builderDelegate: builderDelegate,
        );

        // then
        _expectWidgetWithKey(customIndicatorKey);
      });
    });

    group('When the status is PagingStatus.subsequentPageError', () {
      setUp(() {
        when(() => pagingController.value).thenReturn(
          buildPagingStateWithPopulatedState(
            PopulatedStateOption.errorOnSecondPage,
          ),
        );
      });

      testWidgets(
          'Uses a NewPageErrorIndicator when no custom new page error '
          'indicator is provided.', (tester) async {
        // given
        final builderDelegate = PagedChildBuilderDelegate<int>(
          itemBuilder: (_, __, ___) => Container(),
        );

        // when
        await _pumpPagedLayoutBuilder(
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
        await _pumpPagedLayoutBuilder(
          tester: tester,
          pagingController: pagingController,
          builderDelegate: builderDelegate,
        );

        await tester.pump();

        // then
        _expectWidgetWithKey(customIndicatorKey);
      });
    });

    group('When the status is PagingStatus.ongoing', () {
      setUp(() {
        when(() => pagingController.value).thenReturn(
          buildPagingStateWithPopulatedState(
            PopulatedStateOption.ongoingWithTwoPages,
          ),
        );
      });

      testWidgets(
          'Uses the NewPageProgressIndicator when no custom new page progress '
          'indicator is provided.', (tester) async {
        // given
        final builderDelegate = PagedChildBuilderDelegate<int>(
          itemBuilder: (_, __, ___) => Container(),
        );

        // when
        await _pumpPagedLayoutBuilder(
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
          newPageProgressIndicatorBuilder: (context) =>
              CircularProgressIndicator(
            key: customIndicatorKey,
          ),
        );

        // when
        await _pumpPagedLayoutBuilder(
          tester: tester,
          pagingController: pagingController,
          builderDelegate: builderDelegate,
        );

        await tester.pump();

        // then
        _expectWidgetWithKey(customIndicatorKey);
      });
    });

    group('When the status is PagingStatus.completed', () {
      setUp(() {
        when(() => pagingController.value).thenReturn(
          buildPagingStateWithPopulatedState(
            PopulatedStateOption.completedWithOnePage,
          ),
        );
      });

      testWidgets(
          'Uses the custom no more items indicator when one is provided.',
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
        await _pumpPagedLayoutBuilder(
          tester: tester,
          pagingController: pagingController,
          builderDelegate: builderDelegate,
        );

        await tester.pump();

        // then
        _expectWidgetWithKey(customIndicatorKey);
      });
    });
  });

  group('Page requests', () {
    setUp(() {
      when(
        () => pagingController.addListener(any),
      ).thenReturn(
        null,
      );
      when(
        () => pagingController.notifyPageRequestListeners(any),
      ).thenReturn(
        null,
      );
    });

    testWidgets(
        'Requests the first page when the status is '
        'PagingStatus.loadingFirstPage', (tester) async {
      const firstPageKey = 1;
      // given
      when(() => pagingController.value).thenReturn(
        const PagingState(),
      );
      when(() => pagingController.firstPageKey).thenReturn(
        firstPageKey,
      );
      final builderDelegate = PagedChildBuilderDelegate(
        itemBuilder: (_, __, ___) => Container(),
      );

      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
      );

      // then
      verify(
        () => pagingController.notifyPageRequestListeners(
          firstPageKey,
        ),
      );
    });

    group('Subsequent pages', () {
      late PagedChildBuilderDelegate builderDelegate;
      final pagingState = buildPagingStateWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );
      const invisibleItemsThreshold = 3;

      setUp(() {
        when(() => pagingController.value).thenReturn(
          pagingState,
        );
        when(() => pagingController.nextPageKey).thenReturn(
          pagingState.nextPageKey,
        );
        when(() => pagingController.invisibleItemsThreshold).thenReturn(
          invisibleItemsThreshold,
        );
        when(() => pagingController.itemList).thenReturn(
          pagingState.itemList,
        );

        builderDelegate = PagedChildBuilderDelegate(
          itemBuilder: (_, __, ___) => Container(),
        );
      });

      testWidgets('Doesn\'t request the next page if nextPageKey is null.',
          (tester) async {
        // given
        when(() => pagingController.nextPageKey).thenReturn(
          null,
        );

        // when
        await _pumpPagedLayoutBuilder(
            tester: tester,
            pagingController: pagingController,
            builderDelegate: builderDelegate,
            loadingListingBuilder: (context, itemBuilder, __, ___) {
              final itemCount = pagingState.itemList?.length ?? 0;

              final newPageRequestTriggerIndex =
                  itemCount - invisibleItemsThreshold;

              itemBuilder(
                context,
                newPageRequestTriggerIndex,
              );

              return Container();
            });

        // then
        verifyNever(
          () => pagingController.notifyPageRequestListeners(
            any,
          ),
        );
      });

      testWidgets(
          'Doesn\'t request the next page when building an item that isn\'t '
          'the threshold item.', (tester) async {
        // when
        await _pumpPagedLayoutBuilder(
            tester: tester,
            pagingController: pagingController,
            builderDelegate: builderDelegate,
            loadingListingBuilder: (context, itemBuilder, __, ___) {
              itemBuilder(
                context,
                1,
              );

              return Container();
            });

        // then
        verifyNever(
          () => pagingController.notifyPageRequestListeners(
            pagingState.nextPageKey,
          ),
        );
      });

      testWidgets(
          'Requests the next page when building the threshold item for the '
          'first time', (tester) async {
        // when
        await _pumpPagedLayoutBuilder(
            tester: tester,
            pagingController: pagingController,
            builderDelegate: builderDelegate,
            loadingListingBuilder: (context, itemBuilder, __, ___) {
              final itemCount = pagingState.itemList?.length ?? 0;

              final newPageRequestTriggerIndex =
                  itemCount - invisibleItemsThreshold;
              itemBuilder(
                context,
                newPageRequestTriggerIndex,
              );

              return Container();
            });

        // then
        verify(
          () => pagingController.notifyPageRequestListeners(
            pagingState.nextPageKey,
          ),
        );
      });

      testWidgets(
          'Doesn\'t request the next page when building the threshold item for '
          'the second time', (tester) async {
        // when
        await _pumpPagedLayoutBuilder(
            tester: tester,
            pagingController: pagingController,
            builderDelegate: builderDelegate,
            loadingListingBuilder: (context, itemBuilder, __, ___) {
              final itemCount = pagingState.itemList?.length ?? 0;

              final newPageRequestTriggerIndex =
                  itemCount - invisibleItemsThreshold;
              // First call.
              itemBuilder(
                context,
                newPageRequestTriggerIndex,
              );

              // Second call.
              itemBuilder(
                context,
                newPageRequestTriggerIndex,
              );

              return Container();
            });

        // then
        verify(
          () => pagingController.notifyPageRequestListeners(
            pagingState.nextPageKey,
          ),
        ).called(
          1,
        );
      });
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

Future<void> _pumpPagedLayoutBuilder({
  required WidgetTester tester,
  required PagingController pagingController,
  required PagedChildBuilderDelegate builderDelegate,
  LoadingListingBuilder? loadingListingBuilder,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedLayoutBuilder(
            pagingController: pagingController,
            builderDelegate: builderDelegate,
            layoutBuilder: (_, child) => child,
            errorListingBuilder: (
              context,
              __,
              ___,
              newPageErrorIndicatorBuilder,
            ) =>
                newPageErrorIndicatorBuilder(
              context,
            ),
            loadingListingBuilder: loadingListingBuilder ??
                (
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
