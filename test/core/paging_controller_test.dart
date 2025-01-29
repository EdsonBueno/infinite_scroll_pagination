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
      List<String> fetchPage(int pageKey) {
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

        await Future.value(null);

        expect(fetchCalled, isTrue);
        expect(pagingController.value.pages, [fetchedItems]);
        expect(pagingController.value.keys, [nextPageKey]);
      });

      test('fetches a page synchronously when possible', () async {
        pagingController.fetchNextPage();

        await Future.value(null);

        expect(fetchCalled, isTrue);
        expect(pagingController.value.pages, [fetchedItems]);
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

        await Future.value(null);

        expect(fetchCalled, isFalse);
        expect(pagingController.value.isLoading, isTrue);

        completer.complete(fetchedItems);
        await Future.delayed(Duration.zero);

        expect(pagingController.value.isLoading, isFalse);
      });

      test('stops if next page key is null', () async {
        nextPageKey = null;
        pagingController.fetchNextPage();

        await Future.value(null);

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

        await Future.value(null);

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

        await Future.value(null);

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

      test('cancels previous refresh', () async {
        bool hasBeenCalled = false;
        bool hasFailed = false;

        final completer1 = Completer<List<String>>();
        final completer2 = Completer<List<String>>();

        pagingController = PagingController<int, String>(
            getNextPageKey: (state) => nextPageKey,
            fetchPage: (_) {
              if (hasBeenCalled) {
                return completer2.future;
              } else {
                hasBeenCalled = true;
                return completer1.future;
              }
            });

        final wrongItems = ['Wrong Item 1', 'Wrong Item 2'];

        pagingController.addListener(() {
          try {
            expect(pagingController.value.pages, isNot([wrongItems]));
          } catch (e) {
            hasFailed = true;
          }
        });

        pagingController.fetchNextPage();

        await Future.value(null);

        pagingController.refresh();
        pagingController.fetchNextPage();

        await Future.value(null);

        completer1.complete(wrongItems);
        completer2.complete(fetchedItems);

        await Future.value(null);

        expect(pagingController.value.isLoading, isFalse);
        expect(pagingController.value.pages, [fetchedItems]);
        expect(hasFailed, isFalse);
      });
    });

    group('cancel', () {
      test('resets state and stops fetch', () async {
        pagingController = PagingController<int, String>(
          getNextPageKey: (state) => nextPageKey,
          fetchPage: (page) => Future.value(['Item $page']),
        );

        pagingController.fetchNextPage();

        await Future.value(null);
        await Future.value(null);

        expect(pagingController.value.pages, [
          ['Item 1']
        ]);

        pagingController.fetchNextPage();

        await Future.value(null);

        pagingController.cancel();

        await Future.value(null);

        expect(pagingController.value.isLoading, isFalse);
        expect(pagingController.value.pages, [
          ['Item 1']
        ]);
      });
    });
  });
}
