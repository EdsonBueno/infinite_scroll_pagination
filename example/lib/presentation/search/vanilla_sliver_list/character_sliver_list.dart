import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/character_list_item.dart';
import 'package:breaking_bapp/presentation/search/character_search_input_sliver.dart';
import 'package:breaking_bapp/presentation/search/vanilla_sliver_list/character_sliver_list_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterSliverList extends StatefulWidget {
  @override
  _CharacterSliverListState createState() => _CharacterSliverListState();
}

class _CharacterSliverListState extends State<CharacterSliverList> {
  final CharacterSliverListDataSource _dataSource =
      CharacterSliverListDataSource();

  @override
  Widget build(BuildContext context) => PagedStateChangeListener(
        dataSource: _dataSource,
        onListingWithError: () {
          Scaffold.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong while fetching a new page.'),
            ),
          );
        },
        child: CustomScrollView(
          slivers: <Widget>[
            CharacterSearchInputSliver(
              onChanged: _dataSource.updateSearchTerm,
            ),
            PagedSliverList<int, CharacterSummary>(
              dataSource: _dataSource,
              builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
                itemBuilder: (context, item, index) => CharacterListItem(
                  character: item,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }
}
