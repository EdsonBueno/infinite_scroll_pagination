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
  final PagingController<int, Photo> _pagingController =
      PagingController(firstPageKey: 1);

  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
    _pagingController.addStatusListener(_showError);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await RemoteApi.getPhotos(pageKey, search: _searchTerm);

      final isLastPage = newItems.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _showError(PagingStatus status) async {
    if (status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.retryLastFailedRequest(),
          ),
        ),
      );
    }
  }

  void _updateSearchTerm(String searchTerm) {
    setState(() => _searchTerm = searchTerm);
    _pagingController.refresh();
  }

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
          child: PagedListView<int, Photo>.separated(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              animateTransitions: true,
              itemBuilder: (context, item, index) => ImageListTile(
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
      );
}
