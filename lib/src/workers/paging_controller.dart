import 'package:flutter/foundation.dart';
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
  PagingController({
    @required this.firstPageKey,
    this.invisibleItemsThreshold,
  })  : assert(
          firstPageKey != null,
        ),
        super(
          PagingState<PageKeyType, ItemType>(nextPageKey: firstPageKey),
        );

  /// The number of items before the end of the list that triggers a new fetch.
  final int invisibleItemsThreshold;

  /// The key for the first page to be fetched.
  ///
  /// Needed for being able to reset state.
  final PageKeyType firstPageKey;

  ObserverList<PagingStatusListener> _statusListeners =
      ObserverList<PagingStatusListener>();
  ObserverList<PageRequestListener> _pageRequestListeners =
      ObserverList<PageRequestListener>();

  List<ItemType> get itemList => value.itemList;

  dynamic get error => value.error;
  set error(dynamic newError) {
    value = value.copyWith(
      error: newError,
    );
  }

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

  /// Erases the current error so that we're back to loading state and retries
  /// the latest request.
  void retryLastRequest() {
    error = null;
    notifyPageRequestListeners(nextPageKey);
  }

  /// Resets `this` to its initial state and fetches the initial key again.
  void reset() {
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
    for (final listener in localListeners) {
      if (_statusListeners.contains(listener)) {
        listener(status);
      }
    }
  }

  void addPageRequestListener(PageRequestListener listener) {
    _pageRequestListeners.add(listener);
  }

  void removePageRequestListener(PageRequestListener listener) {
    _pageRequestListeners.remove(listener);
  }

  void notifyPageRequestListeners(PageKeyType pageKey) {
    final localListeners =
        List<PageRequestListener>.from(_pageRequestListeners);
    for (final listener in localListeners) {
      if (_pageRequestListeners.contains(listener)) {
        listener(pageKey);
      }
    }
  }

  @override
  void dispose() {
    _statusListeners = null;
    _pageRequestListeners = null;
    super.dispose();
  }
}
