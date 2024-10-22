import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/src/model/paging_state.dart';

/// A callback to get the next page key.
/// If this function returns `null`, it indicates that there are no more pages to load.
typedef NextPageKeyCallback<PageKeyType extends Object, ItemType extends Object>
    = PageKeyType? Function(PagingState<PageKeyType, ItemType> state);

/// A callback to fetch a page.
typedef FetchPageCallback<PageKeyType extends Object, ItemType extends Object>
    = FutureOr<List<ItemType>> Function(PageKeyType pageKey);

/// A controller to handle a [PagingState].
///
/// This is an unopinionated controller implemented through vanilla Flutter's [ValueNotifier].
/// The controller acts as a mutex to prevent multiple fetches at the same time.
class PagingController<PageKeyType extends Object, ItemType extends Object>
    extends ValueNotifier<PagingState<PageKeyType, ItemType>> {
  PagingController({
    PagingState<PageKeyType, ItemType>? value,
    required NextPageKeyCallback<PageKeyType, ItemType> getNextPageKey,
    required FetchPageCallback<PageKeyType, ItemType> fetchPage,
  })  : _getNextPageKey = getNextPageKey,
        _fetchPage = fetchPage,
        super(
          value ?? PagingState<PageKeyType, ItemType>(),
        );

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
  Object? operation;

  /// Fetches the next page.
  ///
  /// If called while a page is fetching or no more pages are available, this method does nothing.
  void fetchNextPage() async {
    // We are already loading a new page.
    if (this.operation != null) return;

    final operation = this.operation = Object();

    // we use a local copy of value,
    // so that we only send one notification now and at the end of the method.
    PagingState<PageKeyType, ItemType> state = value = value.copyWith(
      isLoading: true,
      error: null,
    );

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

      if (operation != operation) return;

      state = state.copyWith(
        pages: [...?state.pages, newItems],
        keys: [...?state.keys, nextPageKey],
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
      value = state.copyWith(isLoading: false);
      if (operation == this.operation) {
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
}
