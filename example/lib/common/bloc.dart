import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

sealed class PagingEvent {
  const PagingEvent();
}

final class PagingFetchNext extends PagingEvent {}

final class PagingRefresh extends PagingEvent {}

final class PagingCancel extends PagingEvent {}

final class PagingChangeSearch extends PagingEvent {
  const PagingChangeSearch(this.newSearch);

  final String? newSearch;
}

@immutable
final class BlocPagingState<T> extends PagingStateBase<int, T> {
  /// A custom implementation of [PagingState].
  /// It features an additional [search] field for search functionality,
  /// and a [cancelToken] to manage cancellation of ongoing fetch operations.
  BlocPagingState({
    super.pages,
    super.keys,
    super.error,
    super.hasNextPage,
    super.isLoading,
    this.search,
    this.cancelToken,
  });

  final String? search;

  final BlocCancelToken? cancelToken;

  static const _sentinel = Object();

  @override
  BlocPagingState<T> Function({
    List<List<T>>? pages,
    List<int>? keys,
    Object? error,
    bool? hasNextPage,
    bool? isLoading,
    String? search,
    BlocCancelToken? cancelToken,
  }) get copyWith => ({
        Object? pages = _sentinel,
        Object? keys = _sentinel,
        Object? error = _sentinel,
        Object? hasNextPage = _sentinel,
        Object? isLoading = _sentinel,
        Object? search = _sentinel,
        Object? cancelToken = _sentinel,
      }) =>
          BlocPagingState<T>(
            pages: pages == _sentinel ? this.pages : pages as List<List<T>>?,
            keys: keys == _sentinel ? this.keys : keys as List<int>?,
            error: error == _sentinel ? this.error : error,
            hasNextPage: hasNextPage == _sentinel
                ? this.hasNextPage
                : (hasNextPage as bool?) ?? this.hasNextPage,
            isLoading: isLoading == _sentinel
                ? this.isLoading
                : (isLoading as bool?) ?? this.isLoading,
            search: search == _sentinel ? this.search : search as String?,
            cancelToken: cancelToken == _sentinel
                ? this.cancelToken
                : cancelToken as BlocCancelToken?,
          );

  @override
  BlocPagingState<T> reset() => BlocPagingState<T>(
        pages: null,
        keys: null,
        error: null,
        hasNextPage: true,
        isLoading: false,
        search: search,
        cancelToken: BlocCancelToken(),
      );

  @override
  bool operator ==(Object other) =>
      other is BlocPagingState<T> &&
      super == (other) &&
      search == other.search &&
      cancelToken == other.cancelToken;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        search,
        cancelToken,
      );
}

/// A simple implementation of a cancel token.
class BlocCancelToken {
  BlocCancelToken();

  bool _isCancelled = false;
  final _completer = Completer<void>();

  /// Whether the token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// Completes when cancelled.
  Future<void> get whenCancelled => _completer.future;

  /// Cancel the operation.
  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    _completer.complete();
  }
}

class PagingBloc<T> extends Bloc<PagingEvent, BlocPagingState<T>> {
  PagingBloc({
    required this.fetchFn,
  }) : super(BlocPagingState<T>()) {
    on<PagingFetchNext>(_onFetchNext);
    on<PagingRefresh>(_onRefresh);
    on<PagingCancel>(_onCancel);
    on<PagingChangeSearch>(_onChangeSearch);
  }

  final Future<List<T>> Function(int pageKey, String? search)? fetchFn;

  Future<void> _onFetchNext(
    PagingFetchNext event,
    Emitter<BlocPagingState<T>> emit,
  ) async {
    final current = state;
    if (current.isLoading || !current.hasNextPage) return;

    final pageKey = current.lastPageIsEmpty ? null : current.nextIntPageKey;
    if (pageKey == null) {
      emit(current.copyWith(hasNextPage: false));
      return;
    }

    current.cancelToken?.cancel();
    final cancelToken = BlocCancelToken();

    emit(current.copyWith(
      isLoading: true,
      error: null,
      cancelToken: cancelToken,
    ));

    try {
      final result = await fetchFn!(pageKey, current.search);
      if (cancelToken.isCancelled) return;

      final isLastPage = result.isEmpty;
      emit(state.copyWith(
        isLoading: false,
        error: null,
        hasNextPage: !isLastPage,
        pages: [...?state.pages, result],
        keys: [...?state.keys, pageKey],
        cancelToken: null,
      ));
    } catch (e) {
      if (!cancelToken.isCancelled) {
        emit(state.copyWith(isLoading: false, error: e, cancelToken: null));
      }
    }
  }

  Future<void> _onRefresh(
    PagingRefresh event,
    Emitter<BlocPagingState<T>> emit,
  ) async {
    state.cancelToken?.cancel();
    emit(state.reset());
    add(PagingFetchNext());
  }

  Future<void> _onChangeSearch(
    PagingChangeSearch event,
    Emitter<BlocPagingState<T>> emit,
  ) async {
    state.cancelToken?.cancel();
    emit(state.reset().copyWith(search: event.newSearch));
    add(PagingFetchNext());
  }

  Future<void> _onCancel(
    PagingCancel event,
    Emitter<BlocPagingState<T>> emit,
  ) async {
    state.cancelToken?.cancel();
    emit(state.copyWith(isLoading: false, cancelToken: null));
  }

  @override
  Future<void> close() {
    state.cancelToken?.cancel();
    return super.close();
  }
}
