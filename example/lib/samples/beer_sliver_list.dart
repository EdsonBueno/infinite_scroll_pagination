import 'package:brewtiful/remote/beer_summary.dart';
import 'package:brewtiful/remote/remote_api.dart';
import 'package:brewtiful/samples/common/beer_list_item.dart';
import 'package:brewtiful/samples/common/beer_search_input_sliver.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BeerSliverList extends StatefulWidget {
  @override
  _BeerSliverListState createState() => _BeerSliverListState();
}

class _BeerSliverListState extends State<BeerSliverList> {
  static const _pageSize = 17;

  final PagingController<int, BeerSummary> _pagingController =
      PagingController(firstPageKey: 1);

  String? _searchTerm;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _pagingController.addStatusListener((status) {
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
    });

    super.initState();
  }

  Future<void> _fetchPage(pageKey) async {
    try {
      final newItems = await RemoteApi.getBeerList(
        pageKey,
        _pageSize,
        searchTerm: _searchTerm,
      );

      final isLastPage = newItems.length < _pageSize;
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

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: <Widget>[
          BeerSearchInputSliver(
            onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
          ),
          PagedSliverList<int, BeerSummary>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
              animateTransitions: true,
              itemBuilder: (context, item, index) => BeerListItem(
                beer: item,
              ),
            ),
          ),
        ],
      );

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
