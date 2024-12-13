import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state_base.dart';

void main() {
  group('PagingStateBase', () {
    test('constructs with default values', () {
      final state = PagingStateBase<int, String>();

      expect(state.pages, isNull);
      expect(state.keys, isNull);
      expect(state.error, isNull);
      expect(state.hasNextPage, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('constructs with given values', () {
      final state = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Error message',
        hasNextPage: false,
        isLoading: true,
      );

      expect(state.pages, [
        ['Item 1']
      ]);
      expect(state.keys, [1]);
      expect(state.error, 'Error message');
      expect(state.hasNextPage, isFalse);
      expect(state.isLoading, isTrue);
    });

    test('creates immutable lists for pages and keys', () {
      final state = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
      );

      expect(() => (state.pages as List<List<String>>).add(['Item 2']),
          throwsUnsupportedError);
      expect(() => (state.keys as List<int>).add(2), throwsUnsupportedError);
    });

    test('copyWith creates a copy with updated values', () {
      final state = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        hasNextPage: false,
        isLoading: true,
      );

      final newState = state.copyWith(
        pages: [
          ['Item 2']
        ],
        hasNextPage: true,
      );

      expect(newState.pages, [
        ['Item 2']
      ]);
      expect(newState.keys, [1]);
      expect(newState.hasNextPage, isTrue);
      expect(newState.isLoading, isTrue);
    });

    test('copyWith retains values when Omit is passed', () {
      final state = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Initial error',
        hasNextPage: false,
        isLoading: true,
      );

      final newState = state.copyWith(
        pages: const Omit(),
        keys: const Omit(),
        error: const Omit(),
        hasNextPage: const Omit(),
        isLoading: const Omit(),
      );

      expect(newState.pages, state.pages);
      expect(newState.keys, state.keys);
      expect(newState.error, state.error);
      expect(newState.hasNextPage, state.hasNextPage);
      expect(newState.isLoading, state.isLoading);
    });

    test('reset creates a default state', () {
      final state = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Error message',
        hasNextPage: false,
        isLoading: true,
      );

      final resetState = state.reset();

      expect(resetState.pages, isNull);
      expect(resetState.keys, isNull);
      expect(resetState.error, isNull);
      expect(resetState.hasNextPage, isTrue);
      expect(resetState.isLoading, isFalse);
    });

    test('toString outputs expected format', () {
      final state = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Error message',
        hasNextPage: false,
        isLoading: true,
      );

      expect(
        state.toString(),
        contains('pages: [[Item 1]]'),
      );
      expect(
        state.toString(),
        contains('keys: [1]'),
      );
      expect(
        state.toString(),
        contains('error: Error message'),
      );
      expect(
        state.toString(),
        contains('hasNextPage: false'),
      );
      expect(
        state.toString(),
        contains('isLoading: true'),
      );
    });

    test('equality works correctly', () {
      final state1 = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Error message',
        hasNextPage: false,
        isLoading: true,
      );

      final state2 = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Error message',
        hasNextPage: false,
        isLoading: true,
      );

      final state3 = PagingStateBase<int, String>(
        pages: [
          ['Item 2']
        ],
        keys: [2],
        error: 'Different error',
        hasNextPage: true,
        isLoading: false,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('hashCode works correctly', () {
      final state1 = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Error message',
        hasNextPage: false,
        isLoading: true,
      );

      final state2 = PagingStateBase<int, String>(
        pages: [
          ['Item 1']
        ],
        keys: [1],
        error: 'Error message',
        hasNextPage: false,
        isLoading: true,
      );

      expect(state1.hashCode, equals(state2.hashCode));
    });
  });
}
