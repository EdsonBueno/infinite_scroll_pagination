import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/default_indicators/empty_list_indicator.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/default_indicators/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/default_indicators/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/default_indicators/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/default_indicators/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/paged_data_source.dart';

typedef CompletedListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
);

typedef ErrorListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder newPageErrorIndicatorBuilder,
);

typedef LoadingListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder newPageProgressIndicatorBuilder,
);

/// Helps creating infinitely scrolled paged sliver widgets.
///
/// Combines a [PagedDataSource] with a
/// [PagedChildBuilderDelegate] and calls the supplied
/// [loadingListingBuilder], [errorListingBuilder] or
/// [completedListingBuilder] to fill in the gaps.
///
/// For ordinary cases, this widget shouldn't be used directly. Instead, take a
/// look at [PagedSliverList], [PagedSliverGrid],
/// [PagedGridView] and [PagedListView].
class PagedSliverBuilder<PageKeyType, ItemType> extends StatefulWidget {
  const PagedSliverBuilder({
    @required this.dataSource,
    @required this.builderDelegate,
    @required this.loadingListingBuilder,
    @required this.errorListingBuilder,
    @required this.completedListingBuilder,
    this.invisibleItemsThreshold,
    Key key,
  })  : assert(dataSource != null),
        assert(builderDelegate != null),
        assert(loadingListingBuilder != null),
        assert(errorListingBuilder != null),
        assert(completedListingBuilder != null),
        super(key: key);

  /// The data source for paged listings.
  ///
  /// Fetches new items, tells what are the currently loaded ones, what's the
  /// next page's key and whether there is an error.
  ///
  /// This object should generally have a lifetime longer than the
  /// widgets itself; it should be reused each time a paged widget
  /// constructor is called.
  final PagedDataSource<PageKeyType, ItemType> dataSource;

  /// The delegate for building UI pieces of scrolling paged listings.
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// The number of items before the end of the list that triggers a new fetch.
  final int invisibleItemsThreshold;

  /// The builder for an in-progress listing.
  final LoadingListingBuilder loadingListingBuilder;

  /// The builder for an in-progress listing with a failed request.
  final ErrorListingBuilder errorListingBuilder;

  /// The builder for a completed listing.
  final CompletedListingBuilder completedListingBuilder;

  @override
  _PagedSliverBuilderState<PageKeyType, ItemType> createState() =>
      _PagedSliverBuilderState<PageKeyType, ItemType>();
}

class _PagedSliverBuilderState<PageKeyType, ItemType>
    extends State<PagedSliverBuilder<PageKeyType, ItemType>> {
  PagedDataSource<PageKeyType, ItemType> get _dataSource => widget.dataSource;
  PagedChildBuilderDelegate<ItemType> get _builderDelegate =>
      widget.builderDelegate;

  ErrorIndicatorWidgetBuilder get _firstPageErrorIndicatorBuilder =>
      _builderDelegate.firstPageErrorIndicatorBuilder ??
      (_, __, retry) => FirstPageErrorIndicator(
            onTryAgain: retry,
          );

  ErrorIndicatorWidgetBuilder get _newPageErrorIndicatorBuilder =>
      _builderDelegate.newPageErrorIndicatorBuilder ??
      (_, __, retry) => NewPageErrorIndicator(
            onTap: retry,
          );

  WidgetBuilder get _firstPageProgressIndicatorBuilder =>
      _builderDelegate.firstPageProgressIndicatorBuilder ??
      (_) => FirstPageProgressIndicator();

  WidgetBuilder get _newPageProgressIndicatorBuilder =>
      _builderDelegate.newPageProgressIndicatorBuilder ??
      (_) => const NewPageProgressIndicator();

  WidgetBuilder get _noItemsFoundIndicatorBuilder =>
      _builderDelegate.noItemsFoundIndicatorBuilder ??
      (_) => EmptyListIndicator();

  int get _invisibleItemsThreshold => widget.invisibleItemsThreshold ?? 3;

  int get _itemCount => _dataSource.itemCount;

  dynamic get _error => _dataSource.error;

  PageKeyType get _nextKey => _dataSource.nextPageKey;

  /// The index that triggered the last page request.
  ///
  /// Used to avoid duplicate requests on rebuilds.
  int _lastFetchTriggerIndex;

  /// Connects the [_dataSource] with the [_builderDelegate] in order to create
  /// a list item widget and request new items if needed.
  Widget _buildListItemWidget(
    BuildContext context,
    int index,
  ) {
    final item = _dataSource.itemList[index];

    final newFetchTriggerIndex = _itemCount - _invisibleItemsThreshold;

    final hasRequestedPageForTriggerIndex =
        newFetchTriggerIndex == _lastFetchTriggerIndex;

    final isThresholdBiggerThanListSize = newFetchTriggerIndex < 0;

    final isCurrentIndexEqualToTriggerIndex = index == newFetchTriggerIndex;

    final isCurrentIndexEligibleForItemsFetch =
        isThresholdBiggerThanListSize || isCurrentIndexEqualToTriggerIndex;

    if (_hasNextPage &&
        isCurrentIndexEligibleForItemsFetch &&
        !hasRequestedPageForTriggerIndex) {
      _requestNextPage(newFetchTriggerIndex);
    }

    final itemWidget = _builderDelegate.itemBuilder(context, item, index);
    return itemWidget;
  }

  /// Requests a new page from the data source.
  void _requestNextPage(int triggerIndex) {
    _lastFetchTriggerIndex = triggerIndex;
    _dataSource.fetchItems(_nextKey);
  }

  @override
  Widget build(BuildContext context) =>
      // The SliverPadding is used to avoid changing the topmost item inside a
      // CustomScrollView.
      // https://github.com/flutter/flutter/issues/55170
      SliverPadding(
        padding: const EdgeInsets.all(0),
        sliver: AnimatedBuilder(
          animation: _dataSource,
          builder: (context, _) {
            if (_isListingWithLoading) {
              return widget.loadingListingBuilder(
                context,
                _buildListItemWidget,
                _itemCount,
                _newPageProgressIndicatorBuilder,
              );
            }
            if (_isListingCompleted) {
              return widget.completedListingBuilder(
                context,
                _buildListItemWidget,
                _itemCount,
              );
            }

            if (_isLoadingFirstPage) {
              _lastFetchTriggerIndex = null;
              return SliverFillRemaining(
                child: _firstPageProgressIndicatorBuilder(context),
              );
            }

            if (_isListingWithError) {
              return widget.errorListingBuilder(
                context,
                _buildListItemWidget,
                _itemCount,
                (context) => _newPageErrorIndicatorBuilder(
                  context,
                  _error,
                  _dataSource.retryLastRequest,
                ),
              );
            }

            if (_isListEmpty) {
              return SliverFillRemaining(
                child: _noItemsFoundIndicatorBuilder(context),
              );
            } else {
              return SliverFillRemaining(
                child: _firstPageErrorIndicatorBuilder(
                  context,
                  _error,
                  _dataSource.retryLastRequest,
                ),
              );
            }
          },
        ),
      );

  bool get _isListingWithLoading => _isListingInProgress && !_hasError;

  bool get _isListingCompleted => _hasItems && !_hasNextPage;

  bool get _isLoadingFirstPage => _itemCount == null && !_hasError;

  bool get _isListingWithError => _isListingInProgress && _hasError;

  bool get _hasItems => _itemCount != null && _itemCount > 0;

  bool get _isListEmpty => _itemCount != null && _itemCount == 0;

  bool get _hasError => _error != null;

  bool get _isListingInProgress => _hasItems && _hasNextPage;

  bool get _hasNextPage => _nextKey != null;
}

extension on PagedDataSource {
  int get itemCount => itemList?.length;
}
