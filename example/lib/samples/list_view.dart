import 'package:infinite_example/remote/item.dart';
import 'package:infinite_example/remote/api.dart';
import 'package:infinite_example/common/error.dart';
import 'package:infinite_example/common/list_tile.dart';
import 'package:infinite_example/common/search_appbar.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  String? _searchTerm;

  /// This example uses a [PagingController] to manage the paging state.
  ///
  /// This is a robust inbuilt way to store your pagination state.
  /// The controller can also be used in multiple Paged layouts simultaneously,
  /// to share their state.
  late final _pagingController = PagingController<int, Photo>(
    getNextPageKey: (state) {
      // This convenience getter checks if the last returned page is empty.
      // You can replace this with a check if the last page has returned less items than expected,
      // for a more efficient implementation.
      if (state.lastPageIsEmpty) return null;
      // This convenience getter increments the page key by 1, assuming keys start at 1.
      return state.nextIntPageKey;
    },
    fetchPage: (pageKey) => RemoteApi.getPhotos(pageKey, search: _searchTerm),
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addListener(_showError);
  }

  /// This method listens to notifications from the [_pagingController] and
  /// shows a [SnackBar] when an error occurs.
  Future<void> _showError() async {
    if (_pagingController.value.status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.fetchNextPage(),
          ),
        ),
      );
    }
  }

  /// When the search term changes, the controller is refreshed.
  /// The refresh will remove all existing items and fetch the first page again.
  void _updateSearchTerm(String searchTerm) {
    setState(() => _searchTerm = searchTerm);
    _pagingController.refresh();
  }

  /// The controller needs to be disposed when the widget is removed.
  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: SearchAppBar(
          searchTerm: _searchTerm,
          onSearch: _updateSearchTerm,
        ),
        body: RefreshIndicator(
          onRefresh: () async => _pagingController.refresh(),

          /// The [PagingListener] is a widget that listens to the controller and
          /// rebuilds the UI based on the state of the controller.
          /// Its the easiest way to bind your controller to a Paged layout.
          child: PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) =>

                /// Paged layouts rely on a [PagingState] and a [fetchNextPage] function.
                PagedListView<int, Photo>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              itemExtent: 48,
              builderDelegate: PagedChildBuilderDelegate(
                animateTransitions: true,
                itemBuilder: (context, item, index) => ImageListTile(
                  key: ValueKey(item.id),
                  item: item,
                ),
                firstPageErrorIndicatorBuilder: (context) =>
                    CustomFirstPageError(pagingController: _pagingController),
                newPageErrorIndicatorBuilder: (context) =>
                    CustomNewPageError(pagingController: _pagingController),
              ),
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ),
      );
}
