import 'dart:math';

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
  /// This example uses a [PhotoPagesBloc] to manage the paging state.
  ///
  /// The [PhotoPagesBloc] is a custom class we wrote to manage the paging state.
  /// Paged layouts are not limited to using a [PagingController].
  /// You can use any state management solution you prefer.
  ///
  /// In this case, [PhotoPagesBloc] is a bloc class built with RxDart.
  final PhotoPagesBloc _bloc = PhotoPagesBloc();

  _GridType _gridType = _GridType.square;

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<PagingState<int, Photo>>(
        stream: _bloc.onState,
        initialData: _bloc.state,
        builder: (context, snapshot) => LayoutBuilder(
          builder: (context, constraints) => SafeArea(
            child: CustomScrollView(
              slivers: [
                SearchInputSliver(
                  onChanged: (searchTerm) => _bloc.changeSearch(
                    searchTerm,
                  ),
                  getSuggestions: (searchTerm) => (_bloc.state.items
                          ?.expand((photo) => photo.title.split(' '))
                          .where((e) => e.contains(searchTerm))
                          .toSet()
                          .toList() ??
                      []),
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
                                    gridType.name.substring(1),
                              ),
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
                      state: snapshot.data!,
                      fetchNextPage: _bloc.fetchNextPage,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: 1 / 1.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        maxCrossAxisExtent: 200,
                      ),
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) =>
                            CachedNetworkImage(
                          imageUrl: item.thumbnail,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  _GridType.masonry =>
                    PagedSliverMasonryGrid<int, Photo>.extent(
                      state: snapshot.data!,
                      fetchNextPage: _bloc.fetchNextPage,
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
                  _GridType.aligned =>
                    PagedSliverAlignedGrid<int, Photo>.extent(
                      state: snapshot.data!,
                      fetchNextPage: _bloc.fetchNextPage,
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) {
                          final rowCount = constraints.maxWidth ~/ 200;
                          final rowItems = snapshot.data!.items!.sublist(
                            max(0, index - index % rowCount),
                            min(snapshot.data!.items!.length,
                                index - index % rowCount + rowCount),
                          );
                          final averageRatio = rowItems
                                  .map((e) => e.width / e.height)
                                  .reduce((a, b) => a + b) /
                              rowItems.length;

                          return SizedBox(
                            // find out which row this item is in, then alculate the average height of the row
                            height: min(200 / averageRatio, 500),
                            child: CachedNetworkImage(
                              imageUrl: item.thumbnail,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                      showNewPageErrorIndicatorAsGridChild: false,
                      showNewPageProgressIndicatorAsGridChild: false,
                      showNoMoreItemsIndicatorAsGridChild: false,
                    ),
                },
              ],
            ),
          ),
        ),
      );
}
