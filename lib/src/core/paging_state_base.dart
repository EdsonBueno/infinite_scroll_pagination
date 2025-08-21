import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';

/// The default implementation of [PagingState].
///
/// This class is equal to another instance of [PagingStateBase] if
/// all of its fields are deeply equal.
base class PagingStateBase<PageKeyType, ItemType>
    implements PagingState<PageKeyType, ItemType> {
  /// Creates a [PagingStateBase] with the given parameters.
  ///
  /// Ensures that [pages] and [keys] are unmodifiable lists.
  PagingStateBase({
    List<List<ItemType>>? pages,
    List<PageKeyType>? keys,
    this.error,
    this.hasNextPage = true,
    this.isLoading = false,
  })  : assert(
          pages?.length == keys?.length,
          'The length of pages and keys must be equal.',
        ),
        pages = switch (pages) {
          null => null,
          _ => List.unmodifiable(pages.map<List<ItemType>>(List.unmodifiable)),
        },
        keys = switch (keys) {
          null => null,
          _ => List.unmodifiable(keys),
        };

  @override
  final List<List<ItemType>>? pages;

  @override
  final List<PageKeyType>? keys;

  @override
  final Object? error;

  @override
  final bool hasNextPage;

  @override
  final bool isLoading;

  @override
  PagingState<PageKeyType, ItemType> copyWith({
    Defaulted<List<List<ItemType>>?>? pages = const Omit(),
    Defaulted<List<PageKeyType>?>? keys = const Omit(),
    Defaulted<Object?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
  }) =>
      PagingStateBase(
        pages: pages is Omit ? this.pages : pages as List<List<ItemType>>?,
        keys: keys is Omit ? this.keys : keys as List<PageKeyType>?,
        error: error is Omit ? this.error : error as Object?,
        hasNextPage:
            hasNextPage is Omit ? this.hasNextPage : hasNextPage as bool,
        isLoading: isLoading is Omit ? this.isLoading : isLoading as bool,
      );

  @override
  PagingState<PageKeyType, ItemType> reset() => PagingStateBase(
        pages: null,
        keys: null,
        error: null,
        hasNextPage: true,
        isLoading: false,
      );

  @override
  String toString() => '${objectRuntimeType(this, 'PagingStateBase')}'
      '(pages: $pages, keys: $keys, error: $error, hasNextPage: $hasNextPage, '
      'isLoading: $isLoading)';

  static const _equality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PagingState<PageKeyType, ItemType> &&
            _equality.equals(other.pages, pages) &&
            _equality.equals(other.keys, keys) &&
            other.error == error &&
            other.hasNextPage == hasNextPage &&
            other.isLoading == isLoading);
  }

  @override
  int get hashCode => Object.hash(
        _equality.hash(pages),
        _equality.hash(keys),
        error,
        hasNextPage,
        isLoading,
      );
}
