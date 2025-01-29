import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/core/paging_status.dart';

void main() {
  group('PagingStatusExtension', () {
    late PagingState<int, String> pagingState;

    test(
        'returns loadingFirstPage status when loading first page with no items and no error',
        () {
      pagingState = PagingState<int, String>();
      expect(pagingState.status, PagingStatus.loadingFirstPage);
    });

    test(
        'returns firstPageError status when first page has no items and there is an error',
        () {
      pagingState = PagingState<int, String>(error: Exception('Error'));
      expect(pagingState.status, PagingStatus.firstPageError);
    });

    test('returns noItemsFound status when there are no items and no error',
        () {
      pagingState = PagingState<int, String>(
        pages: const [],
        keys: const [],
        hasNextPage: false,
      );
      expect(pagingState.status, PagingStatus.noItemsFound);
    });

    test(
        'returns ongoing status when items exist, there is no error, and more pages are available',
        () {
      pagingState = PagingState<int, String>(
        pages: const [
          ['Item 1']
        ],
        keys: const [1],
        hasNextPage: true,
      );
      expect(pagingState.status, PagingStatus.ongoing);
    });

    test(
        'returns subsequentPageError status when items exist and there is an error',
        () {
      pagingState = PagingState<int, String>(
        pages: const [
          ['Item 1']
        ],
        keys: const [1],
        error: Exception('Error'),
        hasNextPage: true,
      );
      expect(pagingState.status, PagingStatus.subsequentPageError);
    });

    test(
        'returns completed status when items exist and no more pages are available',
        () {
      pagingState = PagingState<int, String>(
        pages: const [
          ['Item 1']
        ],
        keys: const [1],
        hasNextPage: false,
      );
      expect(pagingState.status, PagingStatus.completed);
    });
  });
}
