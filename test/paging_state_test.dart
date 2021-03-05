import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  group('status', () {
    test(
        'when the itemList isn\'t empty, the nextPageKey isn\'t null, '
        'and the error is null, the status should be PagingStatus.ongoing', () {
      const pagingState = PagingState(
        nextPageKey: 2,
        error: null,
        itemList: [1, 2],
      );

      expect(pagingState.status, PagingStatus.ongoing);
    });

    test(
        'when the itemList isn\'t empty, and the nextPageKey is null, '
        'the status should be PagingStatus.completed', () {
      const pagingState = PagingState(
        nextPageKey: null,
        error: null,
        itemList: [1, 2],
      );

      expect(pagingState.status, PagingStatus.completed);
    });

    test(
        'when the itemList and the error are null, '
        'the status should be PagingStatus.loadingFirstPage', () {
      const pagingState = PagingState(
        nextPageKey: null,
        error: null,
        itemList: null,
      );

      expect(pagingState.status, PagingStatus.loadingFirstPage);
    });

    test(
        'when the itemList isn\'t empty, the nextPageKey isn\'t null, and the '
        'error isn\'t null, '
        'the status should be PagingStatus.subsequentPageError', () {
      final pagingState = PagingState(
        nextPageKey: 1,
        error: Error(),
        itemList: const [1, 2],
      );

      expect(pagingState.status, PagingStatus.subsequentPageError);
    });

    test(
        'when the itemList is empty, '
        'the status should be PagingStatus.noItemsFound', () {
      const pagingState = PagingState(
        nextPageKey: null,
        error: null,
        itemList: [],
      );

      expect(pagingState.status, PagingStatus.noItemsFound);
    });
  });

  test('two different instances with equal properties are considered equal',
      () {
    const pagingState1 = PagingState(
      nextPageKey: 2,
      itemList: [1, 2],
      error: null,
    );
    const pagingState2 = PagingState(
      nextPageKey: 2,
      itemList: [1, 2],
      error: null,
    );
    expect(pagingState1, pagingState2);
  });

  test('toString returns the correct values', () {
    const pagingState = PagingState(
      nextPageKey: 2,
      error: null,
      itemList: [1],
    );

    expect(
      pagingState.toString(),
      'PagingState<int, int>(itemList: ┤[1]├, error: null, nextPageKey: 2)',
    );
  });

  group('hashCode', () {
    test('equal states have equal hashCodes', () {
      const pagingState1 = PagingState(
        nextPageKey: 2,
        itemList: [1, 2],
        error: null,
      );
      const pagingState2 = PagingState(
        nextPageKey: 2,
        itemList: [1, 2],
        error: null,
      );

      expect(pagingState1.hashCode, pagingState2.hashCode);
    });

    test('different states have different hashCodes', () {
      const pagingState1 = PagingState(
        nextPageKey: 2,
        itemList: [1, 2],
        error: null,
      );
      const pagingState2 = PagingState(
        nextPageKey: 3,
        itemList: [1, 2, 3, 4],
        error: null,
      );

      expect(pagingState1.hashCode, isNot(pagingState2.hashCode));
    });
  });
}
