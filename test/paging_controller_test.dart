import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

class MockStatusListener extends Mock {
  void call(PagingStatus status);
}

class MockPageRequestListener<PageKeyType> extends Mock {
  void call(PageKeyType pageKey);
}

void main() {
  group('appendPage', () {
    test('appendPage appends the new list to itemList', () {
      // given
      final pagingController = PagingController.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: [1, 2, 3, 4],
          error: null,
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.appendPage([5, 6], 3);

      // then
      expect(pagingController.itemList, [1, 2, 3, 4, 5, 6]);
    });

    test('appendPage changes the nextPageKey', () {
      // given
      final pagingController = PagingController.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: [1, 2, 3, 4],
          error: null,
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.appendPage([5, 6], 3);

      // then
      expect(pagingController.nextPageKey, 3);
    });

    test('appendPage erases the error', () {
      // given
      final pagingController = PagingController.fromValue(
        PagingState(
          nextPageKey: 2,
          itemList: const [1, 2, 3, 4],
          error: Error(),
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.appendPage([5, 6], 3);

      // then
      expect(pagingController.error, null);
    });
  });

  group('appendLastPage', () {
    test('appendLastPage appends the new list to itemList', () {
      // given
      final pagingController = PagingController.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: [1, 2, 3, 4],
          error: null,
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.appendLastPage([5, 6]);

      // then
      expect(pagingController.itemList, [1, 2, 3, 4, 5, 6]);
    });

    test('appendLastPage sets the nextPageKey to null', () {
      // given
      final pagingController = PagingController.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: [1, 2, 3, 4],
          error: null,
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.appendLastPage([5, 6]);

      // then
      expect(pagingController.nextPageKey, null);
    });

    test('appendLastPage erases the error', () {
      // given
      final pagingController = PagingController.fromValue(
        PagingState(
          nextPageKey: 2,
          itemList: const [1, 2, 3, 4],
          error: Error(),
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.appendLastPage([5, 6]);

      // then
      expect(pagingController.error, null);
    });
  });

  test('retryLastFailedRequest erases the error', () {
    // given
    final pagingController = PagingController.fromValue(
      PagingState(
        nextPageKey: 2,
        itemList: const [1, 2, 3, 4],
        error: Error(),
      ),
      firstPageKey: 1,
    );

    // when
    pagingController.retryLastFailedRequest();

    // then
    expect(pagingController.error, null);
  });

  group('refresh', () {
    test('refresh sets itemList to null', () {
      // given
      final pagingController = PagingController.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: [1, 2, 3, 4],
          error: null,
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.refresh();

      // then
      expect(pagingController.itemList, null);
    });

    test('refresh sets the error to null', () {
      // given
      final pagingController = PagingController.fromValue(
        PagingState(
          nextPageKey: 2,
          itemList: const [1, 2, 3, 4],
          error: Error(),
        ),
        firstPageKey: 1,
      );

      // when
      pagingController.refresh();

      // then
      expect(pagingController.error, null);
    });

    test('refresh sets the nextPageKey back to the firstPageKey', () {
      // given
      const firstPageKey = 1;
      final pagingController = PagingController.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: [1, 2, 3, 4],
          error: null,
        ),
        firstPageKey: firstPageKey,
      );

      // when
      pagingController.refresh();

      // then
      expect(pagingController.nextPageKey, firstPageKey);
    });
  });

  group('status listeners', () {
    late PagingController pagingController;
    late PagingStatusListener mockStatusListener;

    setUp(() {
      pagingController = PagingController(firstPageKey: 1);
      mockStatusListener = MockStatusListener();
      pagingController.addStatusListener(mockStatusListener);
    });

    test('assigning a different value notifies status listeners', () {
      // when
      pagingController.value = const PagingState(
        nextPageKey: 2,
        itemList: [
          1,
          2,
        ],
      );

      // then
      verify(mockStatusListener(PagingStatus.ongoing));
    });

    test('removed status listeners aren\'t called', () {
      // when
      pagingController.removeStatusListener(mockStatusListener);
      pagingController.value = const PagingState(
        nextPageKey: 2,
        itemList: [
          1,
          2,
        ],
      );

      // then
      verifyNever(mockStatusListener(PagingStatus.ongoing));
    });
  });

  group('page request listeners', () {
    late PagingController pagingController;
    late PageRequestListener mockPageRequestListener;

    setUp(() {
      pagingController = PagingController(firstPageKey: 1);
      mockPageRequestListener = MockPageRequestListener();
      pagingController.addPageRequestListener(mockPageRequestListener);
    });

    test('added page request listeners are notified', () {
      // when
      const requestedPageKey = 2;
      pagingController.notifyPageRequestListeners(requestedPageKey);

      // then
      verify(mockPageRequestListener(requestedPageKey));
    });

    test('removed page request listeners aren\'t notified', () {
      // when
      const requestedPageKey = 2;
      pagingController.removePageRequestListener(mockPageRequestListener);
      pagingController.notifyPageRequestListeners(requestedPageKey);

      // then
      verifyNever(mockPageRequestListener(requestedPageKey));
    });
  });

  group('dispose', () {
    late PagingController pagingController;
    setUp(() {
      pagingController = PagingController.fromValue(
        const PagingState(
          nextPageKey: 2,
          itemList: [1, 2, 3, 4],
          error: null,
        ),
        firstPageKey: 1,
      );
    });

    test('can\'t add a page request listener to a disposed PagingController',
        () {
      // when
      pagingController.dispose();

      // then
      expect(
        () => pagingController.addPageRequestListener((pageKey) {}),
        throwsException,
      );
    });

    test('can\'t add a status listener to a disposed PagingController', () {
      // when
      pagingController.dispose();

      // then
      expect(
        () => pagingController.addStatusListener((status) {}),
        throwsException,
      );
    });

    test(
        'can\'t remove a page request listener from a disposed '
        'PagingController', () {
      // when
      pagingController.dispose();

      // then
      expect(
        () => pagingController.removePageRequestListener((pageKey) {}),
        throwsException,
      );
    });

    test('can\'t remove a status listener from a disposed PagingController',
        () {
      // when
      pagingController.dispose();

      // then
      expect(
        () => pagingController.removeStatusListener((status) {}),
        throwsException,
      );
    });

    test(
        'can\'t notify page request listeners from a disposed '
        'PagingController', () {
      // when
      pagingController.dispose();

      // then
      expect(
        () => pagingController.notifyPageRequestListeners(3),
        throwsException,
      );
    });

    test('can\'t notify status listener from a disposed PagingController', () {
      // when
      pagingController.dispose();

      // then
      expect(
        () => pagingController.notifyStatusListeners(
          PagingStatus.subsequentPageError,
        ),
        throwsException,
      );
    });
  });
}
