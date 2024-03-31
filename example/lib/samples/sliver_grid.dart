import 'dart:async';

import 'package:infinite_example/remote/item.dart';
import 'package:infinite_example/common/listing_bloc.dart';
import 'package:infinite_example/common/search_input.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

enum _GridType {
  square,
  masonry,
  aligned,
}

class SliverGridScreen extends StatefulWidget {
  const SliverGridScreen({super.key});

  @override
  State<SliverGridScreen> createState() => _SliverGridScreenState();
}

class _SliverGridScreenState extends State<SliverGridScreen> {
  final ListingBloc _bloc = ListingBloc();
  final PagingController<int, Photo> _pagingController =
      PagingController(firstPageKey: 1);
  late StreamSubscription _blocListingStateSubscription;
  _GridType _gridType = _GridType.square;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _bloc.onPageRequestSink.add(pageKey);
    });

    _blocListingStateSubscription =
        _bloc.onNewListingState.listen((listingState) {
      _pagingController.value = PagingState(
        nextPageKey: listingState.nextPageKey,
        error: listingState.error,
        itemList: listingState.itemList,
      );
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _blocListingStateSubscription.cancel();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: CustomScrollView(
          slivers: [
            SearchInputSliver(
              onChanged: (searchTerm) => _bloc.onSearchInputChangedSink.add(
                searchTerm,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      for (final gridType in _GridType.values) ...[
                        ChoiceChip(
                          selected: _gridType == gridType,
                          onSelected: (value) =>
                              setState(() => _gridType = gridType),
                          label: Text(
                              gridType.name.split('').first.toUpperCase() +
                                  gridType.name.substring(1)),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            switch (_gridType) {
              _GridType.square => PagedSliverGrid<int, Photo>(
                  pagingController: _pagingController,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    childAspectRatio: 1 / 1.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    maxCrossAxisExtent: 200,
                  ),
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) => CachedNetworkImage(
                      imageUrl: item.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              _GridType.masonry => PagedSliverMasonryGrid<int, Photo>.extent(
                  pagingController: _pagingController,
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) => AspectRatio(
                      aspectRatio: item.width / item.height,
                      child: CachedNetworkImage(
                        imageUrl: item.thumbnail,
                      ),
                    ),
                  ),
                ),
              _GridType.aligned => PagedSliverAlignedGrid<int, Photo>.extent(
                  pagingController: _pagingController,
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) => AspectRatio(
                      aspectRatio: item.width / item.height,
                      child: CachedNetworkImage(
                        imageUrl: item.thumbnail,
                      ),
                    ),
                  ),
                  showNewPageErrorIndicatorAsGridChild: false,
                  showNewPageProgressIndicatorAsGridChild: false,
                  showNoMoreItemsIndicatorAsGridChild: false,
                ),
            },
          ],
        ),
      );
}
