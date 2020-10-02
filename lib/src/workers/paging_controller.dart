import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/model/paging_state.dart';
import 'package:infinite_scroll_pagination/src/model/paging_status.dart';

typedef PageRequestListener<PageKeyType> = void Function(
  PageKeyType pageKey,
);

typedef PagingStatusListener = void Function(
  PagingStatus status,
);

class PagingController<PageKeyType, ItemType>
    extends ValueNotifier<PagingState<PageKeyType, ItemType>> {
  PagingController({
    @required this.firstPageKey,
    this.invisibleItemsThreshold,
  }) : super(
          PagingState<PageKeyType, ItemType>(nextPageKey: firstPageKey),
        );

  ObserverList<PagingStatusListener> _statusListeners =
      ObserverList<PagingStatusListener>();

  ObserverList<PageRequestListener<PageKeyType>> _pageRequestListeners =
      ObserverList<PageRequestListener<PageKeyType>>();

  /// The number of items before the end of the list that triggers a new fetch.
  final int invisibleItemsThreshold;

  /// The key for the first page to be fetched.
  ///
  /// Needed for being able to reset state.
  final PageKeyType firstPageKey;

  /// The loaded items count.
  int get itemCount => itemList?.length;

  /// Tells whether there's a next page to fetch.
  bool get hasNextPage => nextPageKey != null;

  List<ItemType> get itemList => value.itemList;

  dynamic get error => value.error;
  set error(dynamic newError) {
    value = PagingState<PageKeyType, ItemType>(
      error: newError,
      itemList: itemList,
      nextPageKey: nextPageKey,
    );
  }

  PageKeyType get nextPageKey => value.nextPageKey;

  void appendPage(List<ItemType> newItems, PageKeyType nextPageKey) {
    final previousItems = value.itemList ?? [];
    final itemList = previousItems + newItems;
    value = PagingState<PageKeyType, ItemType>(
      itemList: itemList,
      error: null,
      nextPageKey: nextPageKey,
    );
  }

  void appendLastPage(List<ItemType> newItems) => appendPage(newItems, null);

  /// Erases the current error so that we're back to loading state and retries
  /// the latest request.
  void retryLastRequest() {
    error = null;
    notifyPageRequestListeners(nextPageKey);
  }

  /// Resets `this` to its initial state and fetches the initial key again.
  void refresh() {
    value = PagingState<PageKeyType, ItemType>(
      nextPageKey: firstPageKey,
      error: null,
      itemList: null,
    );

    notifyPageRequestListeners(firstPageKey);
  }

  void addStatusListener(PagingStatusListener listener) {
    _statusListeners.add(listener);
  }

  void removeStatusListener(PagingStatusListener listener) {
    _statusListeners.remove(listener);
  }

  void notifyStatusListeners(PagingStatus status) {
    final localListeners = List<PagingStatusListener>.from(_statusListeners);
    localListeners.forEach((listener) {
      if (_statusListeners.contains(listener)) {
        listener(status);
      }
    });
  }

  void addPageRequestListener(PageRequestListener<PageKeyType> listener) {
    _pageRequestListeners.add(listener);
  }

  void removePageRequestListener(PageRequestListener<PageKeyType> listener) {
    _pageRequestListeners.remove(listener);
  }

  void notifyPageRequestListeners(PageKeyType pageKey) {
    final localListeners =
        List<PageRequestListener<PageKeyType>>.from(_pageRequestListeners);

    localListeners.forEach((listener) {
      if (_pageRequestListeners.contains(listener)) {
        listener(pageKey);
      }
    });
  }

  @override
  void dispose() {
    _statusListeners = null;
    _pageRequestListeners = null;
    super.dispose();
  }
}
