import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/defaults/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/no_items_found_indicator.dart';

import '../utils/paging_controller_utils.dart';

void main() {
  group('PagingStatus.loadingFirstPage', () {
    late PagingState<int, String> state;

    setUp(() {
      state = TestPagingState.loadingFirstPage();
    });

    testWidgets('When no custom first page progress indicator is provided, '
        'a FirstPageProgressIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
      );

      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
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
          itemBuilder: (_, _, _) => Container(),
          firstPageProgressIndicatorBuilder: (context) =>
              Container(key: customIndicatorKey),
        );

        // when
        await _pumpPagedLayoutBuilder(
          tester: tester,
          state: state,
          builderDelegate: builderDelegate,
        );

        // then
        _expectWidgetWithKey(customIndicatorKey);
      },
    );
  });

  group('PagingStatus.firstPageError', () {
    late PagingState<int, String> state;

    setUp(() {
      state = TestPagingState.firstPageError();
    });

    testWidgets('Passes the state error to the custom indicator.', (
      tester,
    ) async {
      Object? receivedError;
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
        firstPageErrorIndicatorBuilder: (context, error) {
          receivedError = error;
          return Container();
        },
      );

      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
        builderDelegate: builderDelegate,
      );

      expect(receivedError, same(state.error));
    });

    testWidgets('When no custom first page error indicator is provided, '
        'a FirstPageErrorIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
      );

      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
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
          itemBuilder: (_, _, _) => Container(),
          firstPageErrorIndicatorBuilder: (context, _) =>
              Container(key: customIndicatorKey),
        );

        // when
        await _pumpPagedLayoutBuilder(
          tester: tester,
          state: state,
          builderDelegate: builderDelegate,
        );

        // then
        _expectWidgetWithKey(customIndicatorKey);
      },
    );
  });

  group('PagingStatus.noItemsFound', () {
    late PagingState<int, String> state;

    setUp(() {
      state = TestPagingState.noItemsFound();
    });

    testWidgets('When no custom no items found indicator is provided, '
        'a NoItemsFoundIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
      );

      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
        builderDelegate: builderDelegate,
      );

      // then
      _expectOneWidgetOfType(NoItemsFoundIndicator);
    });

    testWidgets(
      'A NoItemsFoundIndicator widget is shown when the first page key is null.',
      (tester) async {
        final controller = PagingController<int, String>(
          getNextPageKey: (_) => null,
          fetchPage: (_) => [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PagingListener(
                controller: controller,
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, String>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<String>(
                        itemBuilder: (_, _, _) => Container(),
                      ),
                    ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        _expectOneWidgetOfType(NoItemsFoundIndicator);
        expect(find.byType(FirstPageProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'Uses the custom no items found indicator when one is provided.',
      (tester) async {
        // given
        final customIndicatorKey = UniqueKey();
        final builderDelegate = PagedChildBuilderDelegate<int>(
          itemBuilder: (_, _, _) => Container(),
          noItemsFoundIndicatorBuilder: (context) =>
              Container(key: customIndicatorKey),
        );

        // when
        await _pumpPagedLayoutBuilder(
          tester: tester,
          state: state,
          builderDelegate: builderDelegate,
        );

        // then
        _expectWidgetWithKey(customIndicatorKey);
      },
    );
  });

  group('PagingStatus.subsequentPageError', () {
    late PagingState<int, String> state;

    setUp(() {
      state = TestPagingState.subsequentPageError();
    });

    testWidgets('Passes the state error to the custom indicator.', (
      tester,
    ) async {
      Object? receivedError;
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
        newPageErrorIndicatorBuilder: (context, error) {
          receivedError = error;
          return Container();
        },
      );

      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
        builderDelegate: builderDelegate,
      );

      expect(receivedError, same(state.error));
    });

    testWidgets('When no custom new page error indicator is provided, '
        'a NewPageErrorIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
      );

      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
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
          itemBuilder: (_, _, _) => Container(),
          newPageErrorIndicatorBuilder: (context, _) =>
              Text('Error', key: customIndicatorKey),
        );

        // when
        await _pumpPagedLayoutBuilder(
          tester: tester,
          state: state,
          builderDelegate: builderDelegate,
        );

        await tester.pump();

        // then
        _expectWidgetWithKey(customIndicatorKey);
      },
    );
  });

  group('PagingStatus.ongoing', () {
    late PagingState<int, String> state;

    setUp(() {
      state = TestPagingState.ongoing();
    });

    testWidgets('When no custom new page progress indicator is provided, '
        'a NewPageProgressIndicator widget is shown.', (tester) async {
      // given
      final builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
      );

      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
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
          itemBuilder: (_, _, _) => Container(),
          newPageProgressIndicatorBuilder: (context) =>
              CircularProgressIndicator(key: customIndicatorKey),
        );

        // when
        await _pumpPagedLayoutBuilder(
          tester: tester,
          state: state,
          builderDelegate: builderDelegate,
        );

        await tester.pump();

        // then
        _expectWidgetWithKey(customIndicatorKey);
      },
    );
  });

  group('PagingStatus.completed', () {
    late PagingState<int, String> state;

    setUp(() {
      state = TestPagingState.completed();
    });

    testWidgets(
      'Uses the custom no more items indicator when one is provided.',
      (tester) async {
        // given
        final customIndicatorKey = UniqueKey();
        final builderDelegate = PagedChildBuilderDelegate<int>(
          itemBuilder: (_, _, _) => Container(),
          noMoreItemsIndicatorBuilder: (context) =>
              Text('No more items.', key: customIndicatorKey),
        );

        // when
        await _pumpPagedLayoutBuilder(
          tester: tester,
          state: state,
          builderDelegate: builderDelegate,
        );

        await tester.pump();

        // then
        _expectWidgetWithKey(customIndicatorKey);
      },
    );
  });

  group('First page indicators\' height', () {
    final state = PagingState<int, String>();
    const indicatorHeight = 100.0;
    late Key indicatorKey;
    late Widget progressIndicator;
    late PagedChildBuilderDelegate builderDelegate;
    late Finder indicatorFinder;

    setUp(() {
      indicatorKey = UniqueKey();
      progressIndicator = SizedBox(height: indicatorHeight, key: indicatorKey);
      indicatorFinder = find.byKey(indicatorKey);

      builderDelegate = PagedChildBuilderDelegate<int>(
        itemBuilder: (_, _, _) => Container(),
        firstPageProgressIndicatorBuilder: (_) => progressIndicator,
      );
    });

    testWidgets('By default, first page indicators are expanded to fill the '
        'remaining space', (tester) async {
      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: false,
      );

      // then
      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.height, isNot(indicatorHeight));
    });

    testWidgets('Setting [shrinkWrapFirstPageIndicators] to true '
        'preserves the indicator height', (tester) async {
      // when
      await _pumpPagedLayoutBuilder(
        tester: tester,
        state: state,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: true,
      );

      // then
      final indicatorSize = tester.getSize(indicatorFinder);
      expect(indicatorSize.height, indicatorHeight);
    });
  });

  group('Error indicators fading out', () {
    testWidgets(
      'The first page error indicator rebuilds after the error is cleared.',
      (tester) async {
        await _rebuildErrorIndicatorWhileFadingOut(
          tester: tester,
          errorState: TestPagingState.firstPageError(),
          nextState: TestPagingState.loadingFirstPage(),
          delegateWith: (builder) => PagedChildBuilderDelegate<String>(
            animateTransitions: true,
            itemBuilder: (_, item, _) => Text(item),
            firstPageErrorIndicatorBuilder: builder,
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'The new page error indicator rebuilds after the error is cleared.',
      (tester) async {
        await _rebuildErrorIndicatorWhileFadingOut(
          tester: tester,
          errorState: TestPagingState.subsequentPageError(),
          nextState: TestPagingState.ongoing(),
          delegateWith: (builder) => PagedChildBuilderDelegate<String>(
            animateTransitions: true,
            itemBuilder: (_, item, _) => Text(item),
            newPageErrorIndicatorBuilder: builder,
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
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
  required PagingState<int, String> state,
  required PagedChildBuilderDelegate builderDelegate,
  bool shrinkWrapFirstPageIndicators = false,
}) => _pumpSliver(
  sliver: PagedLayoutBuilder(
    layoutProtocol: PagedLayoutProtocol.sliver,
    state: state,
    fetchNextPage: () => Completer<void>().future,
    builderDelegate: builderDelegate,
    shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
    errorListingBuilder: (context, _, _, newPageErrorIndicatorBuilder) =>
        SliverToBoxAdapter(child: newPageErrorIndicatorBuilder(context)),
    loadingListingBuilder: (context, _, _, newPageProgressIndicatorBuilder) =>
        SliverToBoxAdapter(child: newPageProgressIndicatorBuilder(context)),
    completedListingBuilder: (context, _, _, noMoreItemsIndicatorBuilder) =>
        SliverToBoxAdapter(child: noMoreItemsIndicatorBuilder?.call(context)),
  ),
  tester: tester,
);

Future<void> _pumpSliver({
  required Widget sliver,
  required WidgetTester tester,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: CustomScrollView(slivers: [sliver])),
  ),
);

Future<void> _rebuildErrorIndicatorWhileFadingOut({
  required WidgetTester tester,
  required PagingState<int, String> errorState,
  required PagingState<int, String> nextState,
  required PagedChildBuilderDelegate<String> Function(
    ErrorIndicatorBuilder builder,
  )
  delegateWith,
}) async {
  Widget app(PagingState<int, String> state, double textScale) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: PagedListView<int, String>(
          state: state,
          fetchNextPage: () {},
          builderDelegate: delegateWith((context, error) {
            MediaQuery.textScalerOf(context);
            return Text('$error');
          }),
        ),
      ),
    ),
  );

  await tester.pumpWidget(app(errorState, 1));
  await tester.pumpWidget(app(nextState, 1));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpWidget(app(nextState, 2));
}
