import 'package:infinite_scroll_pagination/src/core/paging_status.dart';

typedef PageRequestListener<PageKeyType> = void Function(
  PageKeyType pageKey,
);

typedef PagingStatusListener = void Function(
  PagingStatus status,
);

abstract class PagingController<PageKeyType, ItemType> {
  void addPageRequestListener(PageRequestListener<PageKeyType> listener);
  void removePageRequestListener(PageRequestListener<PageKeyType> listener);
  void notifyPageRequestListeners();

  void addPagingStatusListener(PagingStatusListener listener);
  void removePagingStatusListener(PagingStatusListener listener);
  void notifyPagingStatusListeners();
}
