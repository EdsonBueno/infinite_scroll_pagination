import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import 'utils/paging_controller_utils.dart';
import 'utils/screen_size_utils.dart';

double get _itemHeight => screenSize.height;
double get _itemWidth => screenSize.width;

void main() {
  group('Page requests', () {
    late MockPageRequestListener mockPageRequestListener;

    setUp(() {
      mockPageRequestListener = MockPageRequestListener();
    });

    testWidgets('Requests first page only once', (tester) async {
      final pagingController = PagingController<int, String>(
        firstPageKey: 1,
      );

      pagingController.addPageRequestListener(mockPageRequestListener.call);

      await _pumpPagedPageView(
        tester: tester,
        pagingController: pagingController,
      );

      verify(mockPageRequestListener(1)).called(1);
    });

    testWidgets('Doesn\'t request a page unnecessarily', (tester) async {
      tester.applyPreferredTestScreenSize();

      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithTwoPages,
      );
      pagingController.addPageRequestListener(mockPageRequestListener.call);

      await _pumpPagedPageView(
        tester: tester,
        pagingController: pagingController,
      );

      verifyZeroInteractions(mockPageRequestListener);
    });

    testWidgets('Requests a new page on scroll', (tester) async {
      tester.applyPreferredTestScreenSize();

      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );
      pagingController.addPageRequestListener(mockPageRequestListener.call);

      await _pumpPagedPageView(
        tester: tester,
        pagingController: pagingController,
      );

      await tester.scrollUntilVisible(
        find.text(
          firstPageItemList[8],
        ),
        250,
      );

      verify(mockPageRequestListener(2)).called(1);
    });

    testWidgets('Show the new page error indicator', (tester) async {
      tester.applyPreferredTestScreenSize();

      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.errorOnSecondPage,
      );

      final customIndicatorKey = UniqueKey();
      final customNewPageErrorIndicator = Text(
        'Error',
        key: customIndicatorKey,
      );

      await _pumpPagedPageView(
        tester: tester,
        pagingController: pagingController,
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

class MockPageRequestListener extends Mock {
  void call(int pageKey);
}

Future<void> _pumpPagedPageView({
  required WidgetTester tester,
  required PagingController<int, String> pagingController,
  Widget? newPageProgressIndicator,
  Widget? newPageErrorIndicator,
  Widget? noMoreItemsIndicator,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedPageView<int, String>(
            pagingController: pagingController,
            scrollDirection: Axis.vertical,
            builderDelegate: PagedChildBuilderDelegate<String>(
              itemBuilder: _buildItem,
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

Widget _buildItem(
  BuildContext context,
  String item,
  int index,
) =>
    SizedBox(
      height: _itemHeight,
      child: Text(
        item,
      ),
    );
