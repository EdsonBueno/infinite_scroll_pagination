import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/model/paging_status.dart';

/// The current item's list, error, and next page key state for a paginated
/// widget.
@immutable
class PagingState<PageKeyType, ItemType> {
  const PagingState({
    this.nextPageKey,
    this.itemList,
    this.error,
  });

  /// List with all items loaded so far.
  final List<ItemType>? itemList;

  /// The current error, if any.
  final dynamic error;

  /// The key for the next page to be fetched.
  final PageKeyType? nextPageKey;

  /// The current pagination status.
  PagingStatus get status {
    if (_isOngoing) {
      return PagingStatus.ongoing;
    }

    if (_isCompleted) {
      return PagingStatus.completed;
    }

    if (_isLoadingFirstPage) {
      return PagingStatus.loadingFirstPage;
    }

    if (_hasSubsequentPageError) {
      return PagingStatus.subsequentPageError;
    }

    if (_isEmpty) {
      return PagingStatus.noItemsFound;
    } else {
      return PagingStatus.firstPageError;
    }
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'PagingState')}(itemList: \u2524'
      '$itemList\u251C, error: $error, nextPageKey: $nextPageKey)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PagingState &&
        other.itemList == itemList &&
        other.error == error &&
        other.nextPageKey == nextPageKey;
  }

  @override
  int get hashCode => hashValues(
        itemList.hashCode,
        error.hashCode,
        nextPageKey.hashCode,
      );

  int? get _itemCount => itemList?.length;

  bool get _hasNextPage => nextPageKey != null;

  bool get _hasItems {
    final itemCount = _itemCount;
    return itemCount != null && itemCount > 0;
  }

  bool get _hasError => error != null;

  bool get _isListingUnfinished => _hasItems && _hasNextPage;

  bool get _isOngoing => _isListingUnfinished && !_hasError;

  bool get _isCompleted => _hasItems && !_hasNextPage;

  bool get _isLoadingFirstPage => _itemCount == null && !_hasError;

  bool get _hasSubsequentPageError => _isListingUnfinished && _hasError;

  bool get _isEmpty => _itemCount != null && _itemCount == 0;
}
