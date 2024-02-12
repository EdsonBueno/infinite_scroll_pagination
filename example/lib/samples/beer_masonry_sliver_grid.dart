import 'dart:async';

import 'package:brewtiful/remote/beer_summary.dart';
import 'package:brewtiful/samples/common/beer_listing_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'common/beer_search_input_sliver.dart';

class BeerMasonrySliverGrid extends StatefulWidget {
  @override
  _BeerMasonrySliverGridState createState() => _BeerMasonrySliverGridState();
}

class _BeerMasonrySliverGridState extends State<BeerMasonrySliverGrid> {
  final BeerListingBloc _bloc = BeerListingBloc();
  final PagingController<int, BeerSummary> _pagingController =
      PagingController(firstPageKey: 1);
  late StreamSubscription _blocListingStateSubscription;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _bloc.onPageRequestSink.add(pageKey);
    });

    // We could've used StreamBuilder, but that would unnecessarily recreate
    // the entire [PagedSliverGrid] every time the state changes.
    // Instead, handling the subscription ourselves and updating only the
    // _pagingController is more efficient.
    _blocListingStateSubscription =
        _bloc.onNewListingState.listen((listingState) {
      _pagingController.value = PagingState(
        nextPageKey: listingState.nextPageKey,
        error: listingState.error,
        itemList: listingState.itemList,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: <Widget>[
          BeerSearchInputSliver(
            onChanged: (searchTerm) => _bloc.onSearchInputChangedSink.add(
              searchTerm,
            ),
          ),
          PagedMasonrySliverGridView.count(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
              itemBuilder: (context, item, index) => CachedNetworkImage(
                imageUrl: item.imageUrl,
              ),
            ),
            crossAxisCount: 5,
          ),
        ],
      );

  @override
  void dispose() {
    _pagingController.dispose();
    _blocListingStateSubscription.cancel();
    _bloc.dispose();
    super.dispose();
  }
}
