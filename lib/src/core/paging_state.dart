import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state_base.dart';

/// Represents the state of a paginated layout.
@immutable
abstract class PagingState<PageKeyType, ItemType> {
  /// Creates a [PagingState] with the given parameters.
  factory PagingState({
    List<List<ItemType>>? pages,
    List<PageKeyType>? keys,
    Object? error,
    bool hasNextPage,
    bool isLoading,
  }) = PagingStateBase<PageKeyType, ItemType>;

  /// The pages fetched so far.
  ///
  /// This contains all pages fetched so far.
  /// The corresponding key for each page is at the same index in [keys].
  List<List<ItemType>>? get pages;

  /// The keys of the pages fetched so far.
  ///
  /// This contains all keys used to fetch pages so far.
  /// The corresponding page for each key is at the same index in [pages].
  List<PageKeyType>? get keys;

  /// The last error that occurred while fetching a page.
  /// This is null if no error occurred.
  Object? get error;

  /// Will be `true` if there is a next page to be fetched.
  bool get hasNextPage;

  /// Will be `true` if a page is currently being fetched.
  bool get isLoading;

  /// Create a copy of this [PagingState] with the given parameters.
  ///
  /// This is a getter to allow a copyWith sentinel pattern.
  /// for more information, see https://github.com/dart-lang/language/issues/140#issuecomment-3070719142
  PagingState<PageKeyType, ItemType> Function({
    List<List<ItemType>>? pages,
    List<PageKeyType>? keys,
    Object? error,
    bool? hasNextPage,
    bool? isLoading,
  }) get copyWith;

  /// Returns a copy this [PagingState] but
  /// all fields are reset to their initial values.
  ///
  /// If you are implementing a custom [PagingState], you should override this method
  /// to reset custom fields as well.
  ///
  /// The reason we use this instead of creating a new instance is so that
  /// a custom [PagingState] can be reset without losing its type.
  PagingState<PageKeyType, ItemType> reset();
}
