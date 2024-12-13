import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import '../utils/paging_controller_utils.dart';
import '../utils/screen_size_utils.dart';

double get _itemHeight => screenSize.height;
double get _itemWidth => screenSize.width;

void main() {
  group('Page requests', () {
    late MockPageRequestListener mockPageRequestListener;

    setUp(() {
      mockPageRequestListener = MockPageRequestListener();
    });

    testWidgets('Requests first page only once', (tester) async {
      await _pumpPagedPageView(
        tester: tester,
        state: TestPagingState.loadingFirstPage(),
        fetchNextPage: mockPageRequestListener.call,
      );

      verify(mockPageRequestListener()).called(1);
    });

    testWidgets('Doesn\'t request a page unnecessarily', (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpPagedPageView(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize * 2),
        fetchNextPage: mockPageRequestListener.call,
      );

      verifyZeroInteractions(mockPageRequestListener);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.applyPreferredTestScreenSize();

      await _pumpPagedPageView(
        tester: tester,
        state: TestPagingState.ongoing(n: pageSize * 2),
        fetchNextPage: mockPageRequestListener.call,
      );

      await tester.scrollUntilVisible(
        find.text('Item ${pageSize * 2}'),
        250,
      );

      verify(mockPageRequestListener()).called(1);
    });

    testWidgets('Show the new page error indicator', (tester) async {
      tester.applyPreferredTestScreenSize();

      final customIndicatorKey = UniqueKey();
      final customNewPageErrorIndicator = Text(
        'Error',
        key: customIndicatorKey,
      );

      await _pumpPagedPageView(
        tester: tester,
        state: TestPagingState.subsequentPageError(),
        fetchNextPage: mockPageRequestListener.call,
        newPageErrorIndicator: customNewPageErrorIndicator,
      );

      await tester.scrollUntilVisible(
        find.byKey(customIndicatorKey),
        _itemWidth,
      );

      expect(find.byKey(customIndicatorKey), findsOneWidget);
    });
  });
}

Future<void> _pumpPagedPageView({
  required WidgetTester tester,
  required PagingState<int, String> state,
  required NextPageCallback fetchNextPage,
  Widget? newPageProgressIndicator,
  Widget? newPageErrorIndicator,
  Widget? noMoreItemsIndicator,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedPageView<int, String>(
            state: state,
            fetchNextPage: fetchNextPage,
            scrollDirection: Axis.vertical,
            builderDelegate: PagedChildBuilderDelegate<String>(
              itemBuilder: buildTestTile(_itemHeight),
              newPageProgressIndicatorBuilder: newPageProgressIndicator != null
                  ? (context) => newPageProgressIndicator
                  : null,
              newPageErrorIndicatorBuilder: newPageErrorIndicator != null
                  ? (context) => newPageErrorIndicator
                  : null,
              noMoreItemsIndicatorBuilder: noMoreItemsIndicator != null
                  ? (context) => noMoreItemsIndicator
                  : null,
            ),
          ),
        ),
      ),
    );
