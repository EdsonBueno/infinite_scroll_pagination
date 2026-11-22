import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  group('PagingStateExtension.hasFetched', () {
    test('is false before a page is fetched', () {
      expect(PagingState<int, String>().hasFetched, isFalse);
    });

    test('is false before a page is fetched when no next page exists', () {
      expect(PagingState<int, String>(hasNextPage: false).hasFetched, isFalse);
    });

    test('is true after an empty page is fetched', () {
      final state = PagingState<int, String>(
        pages: const [[]],
        keys: const [1],
        hasNextPage: false,
      );
      expect(state.hasFetched, isTrue);
    });

    test('is true after a page is fetched while more pages remain', () {
      final state = PagingState<int, String>(
        pages: const [
          ['Item 1'],
        ],
        keys: const [1],
      );
      expect(state.hasFetched, isTrue);
    });
  });
}
