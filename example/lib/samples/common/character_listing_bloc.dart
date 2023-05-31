import 'dart:async';

import 'package:breaking_bapp/remote/character_summary.dart';
import 'package:breaking_bapp/remote/remote_api.dart';
import 'package:rxdart/rxdart.dart';

class CharacterListingState {
  CharacterListingState({
    this.itemList,
    this.error,
    this.nextPageKey = 0,
  });

  final List<CharacterSummary>? itemList;
  final dynamic error;
  final int? nextPageKey;
}

class CharacterListingBloc {
  CharacterListingBloc() {
    _onPageRequest.stream
        .flatMap(_fetchCharacterSummaryList)
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);

    _onSearchInputChangedSubject.stream
        .flatMap((_) => _resetSearch())
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);
  }

  static const _pageSize = 10;

  final _subscriptions = CompositeSubscription();

  final _onNewListingStateController =
      BehaviorSubject<CharacterListingState>.seeded(
    CharacterListingState(),
  );

  Stream<CharacterListingState> get onNewListingState =>
      _onNewListingStateController.stream;

  final _onPageRequest = StreamController<int>();

  Sink<int> get onPageRequestSink => _onPageRequest.sink;

  final _onSearchInputChangedSubject = BehaviorSubject<String?>.seeded(null);

  Sink<String?> get onSearchInputChangedSink =>
      _onSearchInputChangedSubject.sink;

  String? get _searchInputValue => _onSearchInputChangedSubject.value;

  Stream<CharacterListingState> _resetSearch() async* {
    yield CharacterListingState();
    yield* _fetchCharacterSummaryList(0);
  }

  Stream<CharacterListingState> _fetchCharacterSummaryList(int pageKey) async* {
    final lastListingState = _onNewListingStateController.value;
    try {
      final newItems = await RemoteApi.getCharacterList(
        pageKey,
        _pageSize,
        searchTerm: _searchInputValue,
      );
      final isLastPage = newItems.length < _pageSize;
      final nextPageKey = isLastPage ? null : pageKey + newItems.length;
      yield CharacterListingState(
        error: null,
        nextPageKey: nextPageKey,
        itemList: [...lastListingState.itemList ?? [], ...newItems],
      );
    } catch (e) {
      yield CharacterListingState(
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
