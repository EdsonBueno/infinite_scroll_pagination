import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mockito/mockito.dart';

class MockPageRequestListener extends Mock {
  void call();
}

class TestException implements Exception {}

const int pageSize = 10;

List<String> generateItems(int count) =>
    List.generate(count, (index) => 'Item ${index + 1}');

extension TestPagingState on PagingState<int, String> {
  static PagingState<int, String> loadingFirstPage() =>
      PagingState<int, String>();

  static PagingState<int, String> firstPageError() =>
      PagingState<int, String>(error: TestException());

  static PagingState<int, String> noItemsFound() => PagingState<int, String>(
        pages: const [[]],
        keys: const [1],
        hasNextPage: false,
      );

  static PagingState<int, String> ongoing({int n = pageSize}) =>
      PagingState<int, String>(
        pages: [generateItems(n)],
        keys: const [1],
        hasNextPage: true,
      );

  static PagingState<int, String> subsequentPageError({int n = pageSize}) =>
      PagingState<int, String>(
        pages: [generateItems(n)],
        keys: const [1],
        error: TestException(),
        hasNextPage: true,
      );

  static PagingState<int, String> completed({int n = pageSize}) =>
      PagingState<int, String>(
        pages: [generateItems(n)],
        keys: const [1],
        hasNextPage: false,
      );
}

Widget Function(BuildContext, String, int) buildTestTile(double itemHeight) {
  return (
    BuildContext context,
    String item,
    int index,
  ) {
    return SizedBox(
      height: itemHeight,
      child: Text(
        item,
      ),
    );
  };
}
