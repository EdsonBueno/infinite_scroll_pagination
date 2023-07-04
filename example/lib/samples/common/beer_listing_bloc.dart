import 'dart:async';

import 'package:breaking_bapp/remote/beer_summary.dart';
import 'package:breaking_bapp/remote/remote_api.dart';
import 'package:rxdart/rxdart.dart';

class BeerListingState {
  BeerListingState({
    this.itemList,
    this.error,
    this.nextPageKey = 1,
  });

  final List<BeerSummary>? itemList;
  final dynamic error;
  final int? nextPageKey;
}

class BeerListingBloc {
  BeerListingBloc() {
    _onPageRequest.stream
        .flatMap(_fetchBeerSummaryList)
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);

    _onSearchInputChangedSubject.stream
        .flatMap((_) => _resetSearch())
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);
  }

  static const _pageSize = 10;

  final _subscriptions = CompositeSubscription();

  final _onNewListingStateController = BehaviorSubject<BeerListingState>.seeded(
    BeerListingState(),
  );

  Stream<BeerListingState> get onNewListingState =>
      _onNewListingStateController.stream;

  final _onPageRequest = StreamController<int>();

  Sink<int> get onPageRequestSink => _onPageRequest.sink;

  final _onSearchInputChangedSubject = BehaviorSubject<String?>.seeded(null);

  Sink<String?> get onSearchInputChangedSink =>
      _onSearchInputChangedSubject.sink;

  String? get _searchInputValue => _onSearchInputChangedSubject.value;

  Stream<BeerListingState> _resetSearch() async* {
    yield BeerListingState();
    yield* _fetchBeerSummaryList(1);
  }

  Stream<BeerListingState> _fetchBeerSummaryList(int pageKey) async* {
    final lastListingState = _onNewListingStateController.value;
    try {
      final newItems = await RemoteApi.getBeerList(
        pageKey,
        _pageSize,
        searchTerm: _searchInputValue,
      );
      final isLastPage = newItems.length < _pageSize;
      final nextPageKey = isLastPage ? null : pageKey + 1;
      yield BeerListingState(
        error: null,
        nextPageKey: nextPageKey,
        itemList: [
          ...lastListingState.itemList ?? [],
          ...newItems,
        ],
      );
    } catch (e) {
      yield BeerListingState(
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
