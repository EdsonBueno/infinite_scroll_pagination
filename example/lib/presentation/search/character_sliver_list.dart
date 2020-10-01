import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/character_list_item.dart';
import 'package:breaking_bapp/presentation/search/character_search_input_sliver.dart';
import 'package:breaking_bapp/remote_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterSliverList extends StatefulWidget {
  @override
  _CharacterSliverListState createState() => _CharacterSliverListState();
}

class _CharacterSliverListState extends State<CharacterSliverList> {
  final PagingController _pagingController =
      PagingController<int, CharacterSummary>(firstPageKey: 0);
  Object _activeCallbackIdentity;
  String _searchTerm;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _pagingController.addStatusListener((status) {
      if (status == PagingStatus.subsequentPageError) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Something went wrong while fetching a new page.',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _pagingController.retryLastRequest,
            ),
          ),
        );
      }
    });

    super.initState();
  }

  void _fetchPage(pageKey) {
    final callbackIdentity = Object();

    _activeCallbackIdentity = callbackIdentity;
    const pageSize = 17;
    RemoteApi.getCharacterList(pageKey, pageSize, searchTerm: _searchTerm)
        .then((newItems) {
      if (callbackIdentity == _activeCallbackIdentity) {
        final hasFinished = newItems.length < pageSize;
        if (hasFinished) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendNewPage(newItems, nextPageKey);
        }
      }
    }).catchError((error) {
      if (callbackIdentity == _activeCallbackIdentity) {
        _pagingController.error = error;
      }
    });
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: <Widget>[
          CharacterSearchInputSliver(
            onChanged: _updateSearchTerm,
          ),
          PagedSliverList<int, CharacterSummary>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
              itemBuilder: (context, item, index) => CharacterListItem(
                character: item,
              ),
            ),
          ),
        ],
      );

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _activeCallbackIdentity = null;
    _pagingController.dispose();
    super.dispose();
  }
}
