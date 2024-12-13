import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';

/// The default implementation of [PagingState].
///
/// This class is equal to another instance of [PagingStateBase] if
/// all of its fields are deeply equal.
base class PagingStateBase<PageKeyType extends Object, ItemType extends Object>
    implements PagingState<PageKeyType, ItemType> {
  factory PagingStateBase({
    List<List<ItemType>>? pages,
    List<PageKeyType>? keys,
    Object? error,
    bool hasNextPage = true,
    bool isLoading = false,
  }) =>
      PagingStateBase._(
        pages: switch (pages) {
          null => null,
          _ => List.unmodifiable(pages),
        },
        keys: switch (keys) {
          null => null,
          _ => List.unmodifiable(keys),
        },
        error: error,
        hasNextPage: hasNextPage,
        isLoading: isLoading,
      );

  const PagingStateBase._({
    required this.pages,
    required this.keys,
    required this.error,
    required this.hasNextPage,
    required this.isLoading,
  });

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
    FutureOr<List<List<ItemType>>?>? pages = const Omit(),
    FutureOr<List<PageKeyType>?>? keys = const Omit(),
    FutureOr<Object?>? error = const Omit(),
    FutureOr<bool>? hasNextPage = const Omit(),
    FutureOr<bool>? isLoading = const Omit(),
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
      );
}
