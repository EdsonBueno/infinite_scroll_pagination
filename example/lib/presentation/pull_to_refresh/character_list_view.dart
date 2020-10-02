import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/common/character_list_item.dart';
import 'package:breaking_bapp/remote_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  static const _pageSize = 20;

  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0);
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

    RemoteApi.getCharacterList(pageKey, _pageSize).then((newItems) {
      if (callbackIdentity == _activeCallbackIdentity) {
        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
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
