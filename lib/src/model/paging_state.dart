import 'package:flutter/foundation.dart';

/// The current item's list, error, and next page key
/// for a paginated widget.
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

  @override
  String toString() => '${objectRuntimeType(this, 'PagingState')}'
      '(itemList: \u2524$itemList\u251C, error: $error, nextPageKey: $nextPageKey)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PagingState &&
            other.itemList == itemList &&
            other.error == error &&
            other.nextPageKey == nextPageKey);
  }

  @override
  int get hashCode => Object.hash(
        itemList.hashCode,
        error.hashCode,
        nextPageKey.hashCode,
      );
}
