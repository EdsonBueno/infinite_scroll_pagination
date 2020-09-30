import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/core/paging_status.dart';

typedef PageRequestListener<PageKeyType> = void Function(
  PageKeyType pageKey,
);

typedef PagingStatusListener = void Function(
  PagingStatus status,
);

class PagingController<PageKeyType, ItemType>
    extends ValueNotifier<PagingState<PageKeyType, ItemType>> {
  PagingController(PageKeyType firstPageKey)
      : super(
          PagingState<PageKeyType, ItemType>(nextPageKey: firstPageKey),
        );

  List<ItemType> get itemList => value.itemList;

  dynamic get error => value.error;

  PageKeyType get nextPageKey => value.nextPageKey;

  void addNewPage(List<ItemType> newItems, PageKeyType nextPageKey) {
    final previousItems = value.itemList ?? [];
    final itemList = previousItems + newItems;
    value = value.copyWith(
      itemList: itemList,
      error: null,
      nextPageKey: nextPageKey,
    );
  }

  void addLastPage(List<ItemType> newItems) => addNewPage(newItems, null);

  void addPageRequestListener(PageRequestListener<PageKeyType> listener) {}
  void removePageRequestListener(PageRequestListener<PageKeyType> listener) {}
  void notifyPageRequestListeners() {}

  void addPagingStatusListener(PagingStatusListener listener) {}
  void removePagingStatusListener(PagingStatusListener listener) {}
  void notifyPagingStatusListeners() {}
}
