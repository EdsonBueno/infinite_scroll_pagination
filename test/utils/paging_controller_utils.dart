import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

const firstPageItemList = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

const secondPageItemList = [
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20'
];

const pageSize = 10;

PagingController<int, String>
    buildPagingControllerLoadedWithErrorOnSecondPage() =>
        PagingController<int, String>.fromValue(
          PagingState(
            nextPageKey: 2,
            itemList: firstPageItemList,
            error: Error(),
          ),
          firstPageKey: 1,
        );

PagingController<int, String> buildCompletedPagingController() =>
    PagingController<int, String>.fromValue(
      const PagingState(
        nextPageKey: null,
        itemList: firstPageItemList,
      ),
      firstPageKey: 1,
    );

PagingController<int, String> buildPagingControllerLoadedWithTwoPages() =>
    PagingController<int, String>.fromValue(
      const PagingState(
        nextPageKey: 3,
        itemList: [...firstPageItemList, ...secondPageItemList],
      ),
      firstPageKey: 1,
    );

PagingController<int, String> buildPagingControllerLoadedWithFirstPage() =>
    PagingController<int, String>.fromValue(
      const PagingState(
        nextPageKey: 2,
        itemList: firstPageItemList,
      ),
      firstPageKey: 1,
    );
