import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/src/core/paging_status.dart';

@immutable
class PagingState<PageKeyType, ItemType> {
  const PagingState({
    @required this.nextPageKey,
    this.itemList,
    this.error,
  }) : assert(nextPageKey != null);

  final List<ItemType> itemList;

  final dynamic error;

  final PageKeyType nextPageKey;

  /// Creates a copy of this value but with the given fields replaced with the new values.
  PagingState copyWith({
    PageKeyType nextPageKey,
    List<ItemType> itemList,
    dynamic error,
  }) =>
      PagingState(
        nextPageKey: nextPageKey ?? this.nextPageKey,
        itemList: itemList ?? this.itemList,
        error: error ?? this.error,
      );

  @override
  String toString() => '${objectRuntimeType(this, 'PagingState')}'
      '(nextPageKey: \u2524$nextPageKey\u251C, '
      'itemList: $itemList, '
      'error: $error)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PagingState &&
        other.nextPageKey == nextPageKey &&
        other.itemList == itemList &&
        other.error == error;
  }

  @override
  int get hashCode => hashValues(
        nextPageKey.hashCode,
        itemList.hashCode,
        error.hashCode,
      );

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
      return PagingStatus.empty;
    } else {
      return PagingStatus.firstPageError;
    }
  }

  bool get _hasItems => itemCount != null && itemCount > 0;

  int get itemCount => itemList?.length;

  bool get _hasError => error != null;

  bool get _isListingUnfinished => _hasItems && hasNextPage;

  bool get hasNextPage => nextPageKey != null;

  bool get _isOngoing => _isListingUnfinished && !_hasError;

  bool get _isCompleted => _hasItems && !hasNextPage;

  bool get _isLoadingFirstPage => itemCount == null && !_hasError;

  bool get _hasSubsequentPageError => _isListingUnfinished && _hasError;

  bool get _isEmpty => itemCount != null && itemCount == 0;
}
