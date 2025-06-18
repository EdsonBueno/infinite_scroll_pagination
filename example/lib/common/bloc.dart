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
class BlocPagingState<T> implements PagingState<int, T> {
  /// A custom implementation of [PagingState].
  /// It features an additional [search] field for search functionality,
  /// and a [cancelToken] to manage cancellation of ongoing fetch operations.
  const BlocPagingState({
    this.pages,
    this.keys,
    this.error,
    this.hasNextPage = true,
    this.isLoading = false,
    this.search,
    this.cancelToken,
  });

  @override
  final List<List<T>>? pages;

  @override
  final List<int>? keys;

  @override
  final Object? error;

  @override
  final bool hasNextPage;

  @override
  final bool isLoading;

  final String? search;

  final BlocCancelToken? cancelToken;

  @override
  BlocPagingState<T> copyWith({
    Defaulted<List<List<T>>?>? pages = const Omit(),
    Defaulted<List<int>?>? keys = const Omit(),
    Defaulted<Object?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
    Defaulted<String?> search = const Omit(),
    Defaulted<BlocCancelToken?> cancelToken = const Omit(),
  }) =>
      BlocPagingState<T>(
        pages: pages is Omit ? this.pages : pages as List<List<T>>?,
        keys: keys is Omit ? this.keys : keys as List<int>?,
        error: error is Omit ? this.error : error,
        hasNextPage:
            hasNextPage is Omit ? this.hasNextPage : hasNextPage as bool,
        isLoading: isLoading is Omit ? this.isLoading : isLoading as bool,
        search: search is Omit ? this.search : search as String?,
      );

  @override
  BlocPagingState<T> reset() => BlocPagingState<T>(
        pages: null,
        keys: null,
        error: null,
        hasNextPage: true,
        isLoading: false,
        search: this.search,
        cancelToken: BlocCancelToken(),
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
