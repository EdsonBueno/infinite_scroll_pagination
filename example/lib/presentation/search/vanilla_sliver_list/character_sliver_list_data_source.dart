import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/remote_api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterSliverListDataSource
    extends PagedDataSource<int, CharacterSummary> {
  CharacterSliverListDataSource() : super(0);
  static const _pageSize = 17;
  Object _activeCallbackIdentity;

  String _searchTerm;

  @override
  void fetchItems(int pageKey) {
    final callbackIdentity = Object();

    _activeCallbackIdentity = callbackIdentity;

    RemoteApi.getCharacterList(pageKey, _pageSize, searchTerm: _searchTerm)
        .then((newItems) {
      if (callbackIdentity == _activeCallbackIdentity) {
        final hasFinished = newItems.length < _pageSize;
        final nextPageKey = hasFinished ? null : pageKey + newItems.length;
        notifyNewPage(newItems, nextPageKey);
      }
    }).catchError((error) {
      if (callbackIdentity == _activeCallbackIdentity) {
        notifyError(error);
      }
    });
  }

  void updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    refresh();
  }

  @override
  void dispose() {
    _activeCallbackIdentity = null;
    super.dispose();
  }
}
