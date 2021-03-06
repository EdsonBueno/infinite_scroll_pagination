import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

const _firstPageItemList = [1, 2];
const _secondPageItemList = [3, 4];

void main() {
  group('[appendPage] tests', () {
    test('Appends the new list to [itemList]', () {
      // given
      final pagingController = _buildPagingControllerWithOngoingState();

      // when
      pagingController.appendPage(_secondPageItemList, 2);

      // then
      expect(pagingController.itemList, [1, 2, 3, 4]);
    });

    test('Changes [nextPageKey]', () {
      final pagingController = _buildPagingControllerWithOngoingState();

      // when
      pagingController.appendPage(_secondPageItemList, 3);

      // then
      expect(pagingController.nextPageKey, 3);
    });

    test('Sets [error] to null', () {
      // given
      final pagingController = _buildPagingControllerWithSubsequentPageError();

      // when
      pagingController.appendPage(_secondPageItemList, 3);

      // then
      expect(pagingController.error, null);
    });
  });

  group('[appendLastPage] tests', () {
    test('Appends the new list to [itemList]', () {
      // given
      final pagingController = _buildPagingControllerWithOngoingState();

      // when
      pagingController.appendLastPage(_secondPageItemList);

      // then
      expect(pagingController.itemList, [
        ..._firstPageItemList,
        ..._secondPageItemList,
      ]);
    });

    test('Sets [nextPageKey] to null', () {
      // given
      final pagingController = _buildPagingControllerWithOngoingState();

      // when
      pagingController.appendLastPage(_secondPageItemList);

      // then
      expect(pagingController.nextPageKey, null);
    });

    test('Sets [error] to null', () {
      // given
      final pagingController = _buildPagingControllerWithSubsequentPageError();

      // when
      pagingController.appendLastPage(_secondPageItemList);

      // then
      expect(pagingController.error, null);
    });
  });

  test('[retryLastFailedRequest] sets [error] to null', () {
    // given
    final pagingController = _buildPagingControllerWithSubsequentPageError();

    // when
    pagingController.retryLastFailedRequest();

    // then
    expect(pagingController.error, null);
  });

  group('[refresh] tests', () {
    test('Sets [itemList] to null', () {
      // given
      final pagingController = _buildPagingControllerWithOngoingState();

      // when
      pagingController.refresh();

      // then
      expect(pagingController.itemList, null);
    });

    test('Sets [error] to null', () {
      // given
      final pagingController = _buildPagingControllerWithSubsequentPageError();

      // when
      pagingController.refresh();

      // then
      expect(pagingController.error, null);
    });

    test('Sets [nextPageKey] back to the [firstPageKey]', () {
      // given
      final pagingController = _buildPagingControllerWithOngoingState();

      // when
      pagingController.refresh();

      // then
      expect(pagingController.nextPageKey, 1);
    });
  });

  group('[PagingStatusListener]s tests', () {
    late PagingController pagingController;
    late PagingStatusListener mockStatusListener;

    setUp(() {
      pagingController = PagingController(firstPageKey: 1);
      mockStatusListener = MockStatusListener();
      pagingController.addStatusListener(mockStatusListener);
    });

    test('Assigning a new [value] notifies [PagingStatusListener]', () {
      // when
      pagingController.value = _buildFirstPageSuccessfulPagingState();

      // then
      verify(mockStatusListener(PagingStatus.ongoing));
    });

    test('Removed [PagingStatusListener]s aren\'t notified', () {
      // when
      pagingController.removeStatusListener(mockStatusListener);
      pagingController.value = _buildFirstPageSuccessfulPagingState();

      // then
      verifyNever(mockStatusListener(PagingStatus.ongoing));
    });
  });

  group('[PageRequestListener]s tests', () {
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

  group('[dispose] tests', () {
    late PagingController disposedPagingController;
    setUp(() {
      disposedPagingController = _buildPagingControllerWithOngoingState()
        ..dispose();
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
      const itemList = [1, 2, 3, 4];
      pagingController.itemList = itemList;

      // then
      expect(pagingController.value.itemList, itemList);
    });

    test('Assigning to [nextPageKey] changes [value]', () {
      // when
      const nextPageKey = 2;
      pagingController.nextPageKey = 2;

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

PagingController<int, int> _buildPagingControllerWithSubsequentPageError() =>
    PagingController.fromValue(
      PagingState(
        nextPageKey: 2,
        itemList: _firstPageItemList,
        error: Error(),
      ),
      firstPageKey: 1,
    );

PagingController<int, int> _buildPagingControllerWithOngoingState() =>
    PagingController.fromValue(
      _buildFirstPageSuccessfulPagingState(),
      firstPageKey: 1,
    );

PagingState<int, int> _buildFirstPageSuccessfulPagingState() =>
    const PagingState(
      nextPageKey: 2,
      itemList: _firstPageItemList,
      error: null,
    );

class MockStatusListener extends Mock {
  void call(PagingStatus status);
}

class MockPageRequestListener<PageKeyType> extends Mock {
  void call(PageKeyType pageKey);
}
