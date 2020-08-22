import 'dart:async';

import 'package:breaking_bapp/character_summary.dart';
import 'package:breaking_bapp/presentation/character_grid_item.dart';
import 'package:breaking_bapp/presentation/search/bloc_sliver_grid/character_sliver_grid_bloc.dart';
import 'package:breaking_bapp/presentation/search/bloc_sliver_grid/character_sliver_grid_data_source.dart';
import 'package:breaking_bapp/presentation/search/character_search_input_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterSliverGrid extends StatefulWidget {
  @override
  _CharacterSliverGridState createState() => _CharacterSliverGridState();
}

class _CharacterSliverGridState extends State<CharacterSliverGrid> {
  final CharacterSliverGridBloc _bloc = CharacterSliverGridBloc();
  CharacterSliverGridDataSource _dataSource;
  StreamSubscription _blocListingStateSubscription;

  @override
  void initState() {
    _dataSource = CharacterSliverGridDataSource(
      onPageRequested: _bloc.onPageRequestSink.add,
    );

    // We could have used StreamBuilder, but that would unnecessarily recreate
    // the entire [PagedSliverGrid] every time the state changes.
    // Instead, handling the subscription ourselves and updating only the
    // _dataSource is more efficient.
    _blocListingStateSubscription =
        _bloc.onNewListingState.listen((listingState) {
      _dataSource.notifyChange(
        listingState.itemList,
        listingState.error,
        listingState.nextPageKey,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: <Widget>[
          CharacterSearchInputSliver(
            onChanged: _bloc.onSearchInputChangedSink.add,
          ),
          PagedSliverGrid<int, CharacterSummary>(
            dataSource: _dataSource,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 100 / 150,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
            ),
            builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
              itemBuilder: (context, item, index) => CharacterGridItem(
                character: item,
              ),
            ),
          ),
        ],
      );

  @override
  void dispose() {
    _dataSource.dispose();
    _blocListingStateSubscription.cancel();
    super.dispose();
  }
}
