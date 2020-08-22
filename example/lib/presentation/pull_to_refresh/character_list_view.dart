import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/character_list_item.dart';
import 'package:breaking_bapp/presentation/pull_to_refresh/character_list_view_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  final CharacterListViewDataSource _dataSource = CharacterListViewDataSource();

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => Future.sync(
          _dataSource.refresh,
        ),
        child: PagedListView<int, CharacterSummary>.separated(
          dataSource: _dataSource,
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
    _dataSource.dispose();
    super.dispose();
  }
}
