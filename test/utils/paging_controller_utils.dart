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

PagingState<int, String> buildPagingStateWithPopulatedState(
  PopulatedStateOption filledStateOption,
) {
  switch (filledStateOption) {
    case PopulatedStateOption.completedWithOnePage:
      return const PagingState(
        nextPageKey: null,
        itemList: firstPageItemList,
      );
    case PopulatedStateOption.errorOnSecondPage:
      return PagingState(
        nextPageKey: 2,
        itemList: firstPageItemList,
        error: Error(),
      );
    case PopulatedStateOption.ongoingWithOnePage:
      return const PagingState(
        nextPageKey: 2,
        itemList: firstPageItemList,
      );
    case PopulatedStateOption.ongoingWithTwoPages:
      return const PagingState(
        nextPageKey: 3,
        itemList: [...firstPageItemList, ...secondPageItemList],
      );
    case PopulatedStateOption.errorOnFirstPage:
      return PagingState(
        error: Error(),
      );
    case PopulatedStateOption.noItemsFound:
      return const PagingState(
        itemList: [],
      );
  }
}

PagingController<int, String> buildPagingControllerWithPopulatedState(
  PopulatedStateOption filledStateOption,
) {
  final state = buildPagingStateWithPopulatedState(
    filledStateOption,
  );

  return PagingController.fromValue(state, firstPageKey: 1);
}

enum PopulatedStateOption {
  errorOnSecondPage,
  completedWithOnePage,
  ongoingWithTwoPages,
  ongoingWithOnePage,
  errorOnFirstPage,
  noItemsFound,
}
