import 'dart:async';

import 'package:infinite_example/remote/item.dart';
import 'package:infinite_example/remote/api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:rxdart/rxdart.dart';

class PhotoPagesBloc {
  PhotoPagesBloc() {
    _onPageRequest.stream
        .flatMap((_) => _fetch((_stateController.value.keys?.last ?? 0) + 1))
        .listen(_stateController.add)
        .addTo(_subscriptions);

    _onSearchChanged.stream
        .flatMap((_) => _refresh())
        .listen(_stateController.add)
        .addTo(_subscriptions);
  }

  final _subscriptions = CompositeSubscription();

  final _stateController = BehaviorSubject<PagingState<int, Photo>>.seeded(
    PagingState(),
  );

  PagingState<int, Photo> get state => _stateController.value;

  Stream<PagingState<int, Photo>> get onState => _stateController.stream;

  final _onPageRequest = StreamController<void>();

  void fetchNextPage() => _onPageRequest.add(null);

  final _onSearchChanged = BehaviorSubject<String?>.seeded(null);

  void changeSearch(String? value) => _onSearchChanged.add(value);

  String? get _searchInputValue => _onSearchChanged.value;

  Stream<PagingState<int, Photo>> _refresh() async* {
    yield _stateController.value.reset();
    yield* _fetch(1);
  }

  Stream<PagingState<int, Photo>> _fetch(int pageKey) async* {
    final lastListingState = _stateController.value;
    yield lastListingState.copyWith(
      error: null,
      isLoading: true,
    );
    try {
      final newItems = await RemoteApi.getPhotos(
        pageKey,
        search: _searchInputValue,
      );
      final isLastPage = newItems.isEmpty;
      yield lastListingState.copyWith(
        error: null,
        hasNextPage: !isLastPage,
        pages: [
          ...lastListingState.pages ?? [],
          newItems,
        ],
        keys: [
          ...lastListingState.keys ?? [],
          pageKey,
        ],
      );
    } catch (e) {
      yield lastListingState.copyWith(
        error: e,
      );
    }
  }

  void dispose() {
    _onSearchChanged.close();
    _stateController.close();
    _subscriptions.dispose();
    _onPageRequest.close();
  }
}
