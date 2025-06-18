import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_example/common/bloc.dart';
import 'package:infinite_example/remote/remote.dart';
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
  _GridType _gridType = _GridType.square;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => PagingBloc(
          fetchFn: (page, search) => RemoteApi.getPhotos(
            page,
            search: search,
          ),
        ),
        child: BlocBuilder<PagingBloc<Photo>, BlocPagingState<Photo>>(
            builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final bloc = context.read<PagingBloc<Photo>>();
              return SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SearchInputSliver(
                      onChanged: (searchTerm) =>
                          bloc.add(PagingChangeSearch(searchTerm)),
                      getSuggestions: (searchTerm) => (state.items
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
                                    gridType.name
                                            .split('')
                                            .first
                                            .toUpperCase() +
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
                          state: state,
                          fetchNextPage: () => bloc.add(PagingFetchNext()),
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
                          state: state,
                          fetchNextPage: () => bloc.add(PagingFetchNext()),
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
                          state: state,
                          fetchNextPage: () => bloc.add(PagingFetchNext()),
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          builderDelegate: PagedChildBuilderDelegate(
                            itemBuilder: (context, item, index) {
                              final rowCount = constraints.maxWidth ~/ 200;
                              final rowItems = state.items!.sublist(
                                max(0, index - index % rowCount),
                                min(state.items!.length,
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
              );
            },
          );
        }),
      );
}
