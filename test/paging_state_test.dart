import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  group('[status]', () {
    test(
        'When [itemList] isn\'t empty, [nextPageKey] isn\'t null, '
        'and [error] is null, [status] should be [PagingStatus.ongoing]', () {
      const pagingState = PagingState(
        nextPageKey: 2,
        error: null,
        itemList: [1, 2],
      );

      expect(pagingState.status, PagingStatus.ongoing);
    });

    test(
        'When [itemList] isn\'t empty, and [nextPageKey] is null, '
        '[status] should be [PagingStatus.completed]', () {
      const pagingState = PagingState(
        nextPageKey: null,
        error: null,
        itemList: [1, 2],
      );

      expect(pagingState.status, PagingStatus.completed);
    });

    test(
        'When both [itemList] and [error] are null, '
        '[status] should be [PagingStatus.loadingFirstPage]', () {
      const pagingState = PagingState(
        nextPageKey: null,
        error: null,
        itemList: null,
      );

      expect(pagingState.status, PagingStatus.loadingFirstPage);
    });

    test(
        'When [itemList] isn\'t empty, [nextPageKey] isn\'t null, and '
        '[error] isn\'t null, '
        '[status] should be [PagingStatus.subsequentPageError]', () {
      final pagingState = PagingState(
        nextPageKey: 1,
        error: Error(),
        itemList: const [1, 2],
      );

      expect(pagingState.status, PagingStatus.subsequentPageError);
    });

    test(
        'When [itemList] is empty, '
        '[status] should be [PagingStatus.noItemsFound]', () {
      const pagingState = PagingState(
        nextPageKey: null,
        error: null,
        itemList: [],
      );

      expect(pagingState.status, PagingStatus.noItemsFound);
    });
  });

  test('Two different instances with equal properties are considered equal',
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

  test('[toString] returns the correct values', () {
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

  group('[hashCode]', () {
    test('Equal [PagingState]s have equal [hashCode]s', () {
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

    test('Different [PagingState]s have different [hashCode]s', () {
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
