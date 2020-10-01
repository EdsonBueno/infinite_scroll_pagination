import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/character_list_item.dart';
import 'package:breaking_bapp/remote_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(
    firstPageKey: 0,
    invisibleItemsThreshold: 5,
  );
  Object _activeCallbackIdentity;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) {
    final callbackIdentity = Object();

    _activeCallbackIdentity = callbackIdentity;

    const pageSize = 20;
    RemoteApi.getCharacterList(pageKey, pageSize).then((newItems) {
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
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(
          _pagingController.refresh,
        ),
        child: PagedListView<int, CharacterSummary>.separated(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
            itemBuilder: (context, item, index) => CharacterListItem(
              character: item,
            ),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      );

  @override
  void dispose() {
    _activeCallbackIdentity = null;
    _pagingController.dispose();
    super.dispose();
  }
}
