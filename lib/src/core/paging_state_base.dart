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
        pages = List.unmodifiable(
            pages?.map<List<ItemType>>(List.unmodifiable) ?? []),
        keys = List.unmodifiable(keys ?? []);

  @override
  final List<List<ItemType>> pages;

  @override
  final List<PageKeyType> keys;

  @override
  final Object? error;

  @override
  final bool hasNextPage;

  @override
  final bool isLoading;

  static const _sentinel = Object();

  @override
  PagingState<PageKeyType, ItemType> Function({
    List<List<ItemType>>? pages,
    List<PageKeyType>? keys,
    Object? error,
    bool? hasNextPage,
    bool? isLoading,
  }) get copyWith => ({
        Object? pages = _sentinel,
        Object? keys = _sentinel,
        Object? error = _sentinel,
        Object? hasNextPage = _sentinel,
        Object? isLoading = _sentinel,
      }) =>
          PagingStateBase(
            pages: switch (pages) {
              _sentinel || null => this.pages,
              _ => pages as List<List<ItemType>>,
            },
            keys: switch (keys) {
              _sentinel || null => this.keys,
              _ => keys as List<PageKeyType>,
            },
            error: switch (error) {
              _sentinel => this.error,
              _ => error,
            },
            hasNextPage: switch (hasNextPage) {
              _sentinel || null => this.hasNextPage,
              _ => hasNextPage as bool,
            },
            isLoading: switch (isLoading) {
              _sentinel || null => this.isLoading,
              _ => isLoading as bool,
            },
          );

  @override
  PagingState<PageKeyType, ItemType> reset() => PagingStateBase(
        pages: [],
        keys: [],
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
