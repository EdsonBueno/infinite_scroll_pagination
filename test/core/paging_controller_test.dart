import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  group('PagingController', () {
    late PagingController<int, String> pagingController;
    late int? nextPageKey;
    late bool fetchCalled;
    late List<String> fetchedItems;

    setUp(() {
      nextPageKey = 1;
      fetchCalled = false;
      fetchedItems = ['Item 1', 'Item 2'];

      getNextPageKey(state) => nextPageKey;
      fetchPage(pageKey) {
        fetchCalled = true;
        return fetchedItems;
      }

      pagingController = PagingController<int, String>(
        getNextPageKey: getNextPageKey,
        fetchPage: fetchPage,
      );
    });

    group('fetchNextPage', () {
      test('requests the next page', () async {
        pagingController.fetchNextPage();

        expect(fetchCalled, isTrue);
        expect(pagingController.value.pages, [
          ['Item 1', 'Item 2']
        ]);
        expect(pagingController.value.keys, [nextPageKey]);
      });

      test('fetches a page synchronously when possible', () {
        pagingController.fetchNextPage();

        expect(fetchCalled, isTrue);
        expect(pagingController.value.pages, [
          ['Item 1', 'Item 2']
        ]);
        expect(pagingController.value.keys, [nextPageKey]);
      });

      test('only runs one fetch at a given time', () async {
        final completer = Completer<List<String>>();

        pagingController = PagingController<int, String>(
          getNextPageKey: (state) => nextPageKey,
          fetchPage: (_) => completer.future,
        );

        pagingController.fetchNextPage();
        pagingController.fetchNextPage();

        expect(fetchCalled, isFalse);
        expect(pagingController.value.isLoading, isTrue);

        completer.complete(fetchedItems);
        await Future.delayed(Duration.zero);

        expect(pagingController.value.isLoading, isFalse);
      });

      test('stops if next page key is null', () async {
        nextPageKey = null;
        pagingController.fetchNextPage();

        expect(fetchCalled, isFalse);
        expect(pagingController.value.hasNextPage, isFalse);
      });

      test('stops if no more pages are available', () async {
        pagingController.value =
            pagingController.value.copyWith(hasNextPage: false);
        pagingController.fetchNextPage();
        expect(fetchCalled, isFalse);
      });

      test('catches Exceptions', () async {
        pagingController = PagingController<int, String>(
          getNextPageKey: (state) => nextPageKey,
          fetchPage: (_) => throw Exception(),
        );

        pagingController.fetchNextPage();

        expect(pagingController.value.isLoading, isFalse);
        expect(pagingController.value.error, isA<Exception>());
      });

      test('rethrows Errors', () async {
        pagingController = PagingController<int, String>(
          getNextPageKey: (state) => nextPageKey,
          fetchPage: (_) => throw Error(),
        );

        expect(() async => pagingController.fetchNextPage(),
            throwsA(isA<Error>()));
        expect(pagingController.value.isLoading, isFalse);
        expect(pagingController.value.error, isA<Error>());
      });
    });

    group('refresh', () {
      test('resets state', () async {
        pagingController.value = PagingState<int, String>(
          pages: const [
            ['Item 1']
          ],
          keys: const [1],
        );

        pagingController.refresh();

        expect(pagingController.value.pages, isNull);
        expect(pagingController.value.keys, isNull);
        expect(pagingController.value.isLoading, isFalse);
        expect(pagingController.value.error, isNull);
      });
    });

    group('cancel', () {
      test('resets state and stops fetch', () async {
        final Completer<List<String>> completer = Completer<List<String>>();

        pagingController = PagingController<int, String>(
          getNextPageKey: (state) => nextPageKey,
          fetchPage: (_) => completer.future,
        );

        pagingController.fetchNextPage();

        expect(pagingController.value.isLoading, isTrue);

        pagingController.cancel();

        expect(pagingController.value.isLoading, isFalse);
        completer.complete(fetchedItems);

        await Future.delayed(Duration.zero);
        expect(pagingController.value.isLoading, isFalse);
        expect(pagingController.value.pages, [
          ['Item 1', 'Item 2']
        ]);
      });
    });
  });
}
