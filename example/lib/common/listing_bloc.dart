import 'dart:async';

import 'package:infinite_example/remote/item.dart';
import 'package:infinite_example/remote/api.dart';
import 'package:rxdart/rxdart.dart';

class ListingState {
  ListingState({
    this.itemList,
    this.error,
    this.nextPageKey = 1,
  });

  final List<Photo>? itemList;
  final dynamic error;
  final int? nextPageKey;
}

class ListingBloc {
  ListingBloc() {
    _onPageRequest.stream
        .flatMap(_fetch)
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);

    _onSearchInputChangedSubject.stream
        .flatMap((_) => _refresh())
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);
  }

  final _subscriptions = CompositeSubscription();

  final _onNewListingStateController = BehaviorSubject<ListingState>.seeded(
    ListingState(),
  );

  Stream<ListingState> get onNewListingState =>
      _onNewListingStateController.stream;

  final _onPageRequest = StreamController<int>();

  Sink<int> get onPageRequestSink => _onPageRequest.sink;

  final _onSearchInputChangedSubject = BehaviorSubject<String?>.seeded(null);

  Sink<String?> get onSearchInputChangedSink =>
      _onSearchInputChangedSubject.sink;

  String? get _searchInputValue => _onSearchInputChangedSubject.value;

  Stream<ListingState> _refresh() async* {
    yield ListingState();
    yield* _fetch(1);
  }

  Stream<ListingState> _fetch(int pageKey) async* {
    final lastListingState = _onNewListingStateController.value;
    try {
      final newItems = await RemoteApi.getPhotos(
        pageKey,
        search: _searchInputValue,
      );
      final isLastPage = newItems.isEmpty;
      final nextPageKey = isLastPage ? null : pageKey + 1;
      yield ListingState(
        error: null,
        nextPageKey: nextPageKey,
        itemList: [
          ...lastListingState.itemList ?? [],
          ...newItems,
        ],
      );
    } catch (e) {
      yield ListingState(
        error: e,
        nextPageKey: lastListingState.nextPageKey,
        itemList: lastListingState.itemList,
      );
    }
  }

  void dispose() {
    _onSearchInputChangedSubject.close();
    _onNewListingStateController.close();
    _subscriptions.dispose();
    _onPageRequest.close();
  }
}
