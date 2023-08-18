import 'dart:async';

import 'package:brewtiful/remote/beer_summary.dart';
import 'package:brewtiful/samples/common/beer_listing_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BeerMasonryGrid extends StatefulWidget {
  @override
  _BeerMasonryGridState createState() => _BeerMasonryGridState();
}

class _BeerMasonryGridState extends State<BeerMasonryGrid> {
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
  Widget build(BuildContext context) => PagedMasonryGridView.count(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
          itemBuilder: (context, item, index) => CachedNetworkImage(
            imageUrl: item.imageUrl,
          ),
        ),
        crossAxisCount: 2,
      );

  @override
  void dispose() {
    _pagingController.dispose();
    _blocListingStateSubscription.cancel();
    _bloc.dispose();
    super.dispose();
  }
}
