import 'dart:async';

import 'package:breaking_bapp/presentation/search/bloc_sliver_grid/character_sliver_grid_states.dart';
import 'package:breaking_bapp/remote_api.dart';
import 'package:rxdart/rxdart.dart';

class CharacterSliverGridBloc {
  CharacterSliverGridBloc() {
    _onPageRequest.stream
        .flatMap(_fetchCharacterSummaryList)
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);

    _onSearchInputChangedSubject.stream
        .flatMap((_) => _resetSearch())
        .listen(_onNewListingStateController.add)
        .addTo(_subscriptions);
  }

  final _subscriptions = CompositeSubscription();

  final _onNewListingStateController =
      BehaviorSubject<CharacterListingState>.seeded(
    CharacterListingState(),
  );

  Stream<CharacterListingState> get onNewListingState =>
      _onNewListingStateController.stream;

  final _onPageRequest = StreamController<int>();

  Sink<int> get onPageRequestSink => _onPageRequest.sink;

  final _onSearchInputChangedSubject = BehaviorSubject<String>();

  Sink<String> get onSearchInputChangedSink =>
      _onSearchInputChangedSubject.sink;

  String get searchInputValue => _onSearchInputChangedSubject.value;

  Stream<CharacterListingState> _resetSearch() async* {
    yield CharacterListingState();
    yield* _fetchCharacterSummaryList(0);
  }

  Stream<CharacterListingState> _fetchCharacterSummaryList(int pageKey) async* {
    final lastListingState = _onNewListingStateController.value;
    try {
      const pageSize = 20;
      final newItems = await RemoteApi.getCharacterList(
        pageKey,
        pageSize,
        searchTerm: searchInputValue,
      );
      final hasFinished = newItems.length < pageSize;
      final nextPageKey = hasFinished ? null : pageKey + newItems.length;
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
