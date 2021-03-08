import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

import 'utils/paging_controller_utils.dart';

void main() {
  group('[appendPage]', () {
    test('Appends the new list to [itemList]', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );

      // when
      pagingController.appendPage(secondPageItemList, 2);

      // then
      expect(pagingController.itemList, [
        ...firstPageItemList,
        ...secondPageItemList,
      ]);
    });

    test('Changes [nextPageKey]', () {
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );
      const newNextPageKey = 3;

      // when
      pagingController.appendPage(secondPageItemList, newNextPageKey);

      // then
      expect(pagingController.nextPageKey, newNextPageKey);
    });

    test('Sets [error] to null', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.errorOnSecondPage,
      );

      // when
      pagingController.appendPage(secondPageItemList, 3);

      // then
      expect(pagingController.error, null);
    });
  });

  group('[appendLastPage]', () {
    test('Appends the new list to [itemList]', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );

      // when
      pagingController.appendLastPage(secondPageItemList);

      // then
      expect(pagingController.itemList, [
        ...firstPageItemList,
        ...secondPageItemList,
      ]);
    });

    test('Sets [nextPageKey] to null', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );

      // when
      pagingController.appendLastPage(secondPageItemList);

      // then
      expect(pagingController.nextPageKey, null);
    });

    test('Sets [error] to null', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.errorOnSecondPage,
      );

      // when
      pagingController.appendLastPage(secondPageItemList);

      // then
      expect(pagingController.error, null);
    });
  });

  test('[retryLastFailedRequest] sets [error] to null', () {
    // given
    final pagingController = buildPagingControllerWithPopulatedState(
      PopulatedStateOption.errorOnSecondPage,
    );

    // when
    pagingController.retryLastFailedRequest();

    // then
    expect(pagingController.error, null);
  });

  group('[refresh]', () {
    test('Sets [itemList] to null', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );

      // when
      pagingController.refresh();

      // then
      expect(pagingController.itemList, null);
    });

    test('Sets [error] to null', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.errorOnSecondPage,
      );

      // when
      pagingController.refresh();

      // then
      expect(pagingController.error, null);
    });

    test('Sets [nextPageKey] back to [firstPageKey]', () {
      // given
      final pagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );

      // when
      pagingController.refresh();

      // then
      expect(pagingController.nextPageKey, 1);
    });
  });

  group('[PagingStatusListener]', () {
    late PagingController<int, String> pagingController;
    late PagingStatusListener mockStatusListener;

    setUp(() {
      pagingController = PagingController(firstPageKey: 1);
      mockStatusListener = MockStatusListener();
      pagingController.addStatusListener(mockStatusListener);
    });

    test('Assigning a new [value] notifies [PagingStatusListener]', () {
      // when
      pagingController.value = buildPagingStateWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );

      // then
      verify(mockStatusListener(PagingStatus.ongoing));
    });

    test('Removed [PagingStatusListener]s aren\'t notified', () {
      // when
      pagingController.removeStatusListener(mockStatusListener);
      pagingController.value = buildPagingStateWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      );

      // then
      verifyNever(mockStatusListener(PagingStatus.ongoing));
    });
  });

  group('[PageRequestListener]', () {
    late PagingController pagingController;
    late PageRequestListener mockPageRequestListener;
    const requestedPageKey = 2;

    setUp(() {
      pagingController = PagingController(firstPageKey: 1);
      mockPageRequestListener = MockPageRequestListener();
      pagingController.addPageRequestListener(mockPageRequestListener);
    });

    test('[PageRequestListener]s are notified', () {
      // when
      pagingController.notifyPageRequestListeners(requestedPageKey);

      // then
      verify(mockPageRequestListener(requestedPageKey));
    });

    test('Removed [PageRequestListener]s aren\'t notified', () {
      // when
      pagingController.removePageRequestListener(mockPageRequestListener);
      pagingController.notifyPageRequestListeners(requestedPageKey);

      // then
      verifyNever(mockPageRequestListener(requestedPageKey));
    });
  });

  group('[dispose]', () {
    late PagingController disposedPagingController;
    setUp(() {
      disposedPagingController = buildPagingControllerWithPopulatedState(
        PopulatedStateOption.ongoingWithOnePage,
      )..dispose();
    });

    test('Can\'t add a [PageRequestListener] to a disposed [PagingController]',
        () {
      expect(
        () => disposedPagingController.addPageRequestListener((pageKey) {}),
        throwsException,
      );
    });

    test('Can\'t add a [PagingStatusListener] to a disposed PagingController',
        () {
      expect(
        () => disposedPagingController.addStatusListener((status) {}),
        throwsException,
      );
    });

    test(
        'Can\'t remove a [PageRequestListener] from a disposed '
        '[PagingController]', () {
      expect(
        () => disposedPagingController.removePageRequestListener((pageKey) {}),
        throwsException,
      );
    });

    test(
        'Can\'t remove a [PagingStatusListener] from a disposed '
        '[PagingController]', () {
      expect(
        () => disposedPagingController.removeStatusListener((status) {}),
        throwsException,
      );
    });

    test(
        'Can\'t notify [PageRequestListener]s from a disposed '
        '[PagingController]', () {
      expect(
        () => disposedPagingController.notifyPageRequestListeners(3),
        throwsException,
      );
    });

    test(
        'Can\'t notify [PagingStatusListener]s from a disposed '
        '[PagingController]', () {
      expect(
        () => disposedPagingController.notifyStatusListeners(
          PagingStatus.subsequentPageError,
        ),
        throwsException,
      );
    });
  });

  group('Computed Properties tests', () {
    late PagingController pagingController;

    setUp(() {
      pagingController = PagingController(firstPageKey: 1);
    });

    test('Assigning to [itemList] changes [value]', () {
      // when
      pagingController.itemList = firstPageItemList;

      // then
      expect(pagingController.value.itemList, firstPageItemList);
    });

    test('Assigning to [nextPageKey] changes [value]', () {
      // when
      const nextPageKey = 2;
      pagingController.nextPageKey = nextPageKey;

      // then
      expect(pagingController.value.nextPageKey, nextPageKey);
    });

    test('Assigning to [error] changes [value]', () {
      // when
      final error = Error();
      pagingController.error = error;

      // then
      expect(pagingController.value.error, error);
    });
  });
}

class MockStatusListener extends Mock {
  void call(PagingStatus status);
}

class MockPageRequestListener<PageKeyType> extends Mock {
  void call(PageKeyType pageKey);
}
