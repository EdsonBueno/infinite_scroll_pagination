import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';

/// A callback to get the next page key.
/// If this function returns `null`, it indicates that there are no more pages to load.
typedef NextPageKeyCallback<PageKeyType, ItemType> = PageKeyType? Function(
    PagingState<PageKeyType, ItemType> state);

/// A callback to fetch a page.
typedef FetchPageCallback<PageKeyType, ItemType> = FutureOr<List<ItemType>>
    Function(PageKeyType pageKey);

/// A controller to handle a [PagingState].
///
/// This is an unopinionated controller implemented through vanilla Flutter's [ValueNotifier].
/// The controller acts as a mutex to prevent multiple fetches at the same time.
///
/// Note that for convenience, fetch operations are not atomic.
/// The state may be updated during a fetch operation. This should be done fully synchronously,
/// as otherwise, the state may become desynchronized.
class PagingController<PageKeyType, ItemType>
    extends ValueNotifier<PagingState<PageKeyType, ItemType>> {
  PagingController({
    PagingState<PageKeyType, ItemType>? value,
    required int limitPerPage;
    required NextPageKeyCallback<PageKeyType, ItemType> getNextPageKey,
    required FetchPageCallback<PageKeyType, ItemType> fetchPage,
  })  : _getNextPageKey = getNextPageKey,
        _fetchPage = fetchPage,
        super(
          value ?? PagingState<PageKeyType, ItemType>(),
        );

  /// Variable for checking if already reached the last page
  final int limitPerPage;

  /// The function to get the next page key.
  /// If this function returns `null`, it indicates that there are no more pages to load.
  final NextPageKeyCallback<PageKeyType, ItemType> _getNextPageKey;

  /// The function to fetch a page.
  final FetchPageCallback<PageKeyType, ItemType> _fetchPage;

  /// Keeps track of the current operation.
  /// If the operation changes during its execution, the operation is cancelled.
  ///
  /// Instead of using this property directly, use [fetchNextPage], [refresh], or [cancel].
  /// If you are extending this class, check and set this property before and after the fetch operation.
  @protected
  @visibleForTesting
  Object? operation;

  /// Fetches the next page.
  ///
  /// If called while a page is fetching or no more pages are available, this method does nothing.
  void fetchNextPage() async {
    // We are already loading a new page.
    if (this.operation != null) return;

    final operation = this.operation = Object();

    value = value.copyWith(
      isLoading: true,
      error: null,
    );

    // we use a local copy of value,
    // so that we only send one notification now and at the end of the method.
    PagingState<PageKeyType, ItemType> state = value;

    try {
      // There are no more pages to load.
      if (!state.hasNextPage) return;

      final nextPageKey = _getNextPageKey(state);

      // We are at the end of the list.
      if (nextPageKey == null) {
        state = state.copyWith(hasNextPage: false);
        return;
      }

      final fetchResult = _fetchPage(nextPageKey);
      List<ItemType> newItems;

      // If the result is synchronous, we can directly assign it in the same tick.
      if (fetchResult is Future) {
        newItems = await fetchResult;
      } else {
        newItems = fetchResult;
      }

      // Update our state in case it was modified during the fetch operation.
      // This beaks atomicity, but is necessary to allow users to modify the state during a fetch.
      state = value;

      // Check if there is no more items left / reached last page
      bool isLastPage = newItems.isEmpty || newItems.length < limit;

      state = state.copyWith(
        pages: [...?state.pages, newItems],
        keys: [...?state.keys, nextPageKey],
        hasNextPage: !isLastPage,
      );
    } catch (error) {
      state = state.copyWith(error: error);

      if (error is! Exception) {
        // Errors which are not exceptions indicate that something
        // went unexpectedly wrong. These errors are rethrown
        // so they can be logged and investigated.
        rethrow;
      }
    } finally {
      if (operation == this.operation) {
        value = state.copyWith(isLoading: false);
        this.operation = null;
      }
    }
  }

  /// Restarts the pagination process.
  ///
  /// This cancels the current fetch operation and resets the state.
  void refresh() {
    operation = null;
    value = value.reset();
  }

  /// Cancels the current fetch operation.
  ///
  /// This can be called right before a call to [fetchNextPage] to force a new fetch.
  void cancel() {
    operation = null;
    value = value.copyWith(isLoading: false);
  }

  @override
  void dispose() {
    operation = null;
    super.dispose();
  }
}
