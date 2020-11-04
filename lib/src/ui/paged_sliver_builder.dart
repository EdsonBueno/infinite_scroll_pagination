import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/model/paging_state.dart';
import 'package:infinite_scroll_pagination/src/model/paging_status.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/no_items_found_indicator.dart';

typedef CompletedListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder noMoreItemsIndicatorBuilder,
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

/// Assists the creation of infinitely scrolled paged sliver widgets.
///
/// Combines a [PagingController] with a
/// [PagedChildBuilderDelegate] and calls the supplied
/// [loadingListingBuilder], [errorListingBuilder] or
/// [completedListingBuilder] for filling in the gaps.
///
/// For ordinary cases, this widget shouldn't be used directly. Instead, take a
/// look at [PagedSliverList], [PagedSliverGrid],
/// [PagedGridView] and [PagedListView].
class PagedSliverBuilder<PageKeyType, ItemType> extends StatefulWidget {
  const PagedSliverBuilder({
    @required this.pagingController,
    @required this.builderDelegate,
    @required this.loadingListingBuilder,
    @required this.errorListingBuilder,
    @required this.completedListingBuilder,
    this.shrinkWrapFirstPageIndicators = false,
    Key key,
  })  : assert(pagingController != null),
        assert(builderDelegate != null),
        assert(loadingListingBuilder != null),
        assert(errorListingBuilder != null),
        assert(completedListingBuilder != null),
        super(key: key);

  /// The controller for paged listings.
  ///
  /// Informs the current state of the pagination and requests new items from
  /// its listeners.
  final PagingController<PageKeyType, ItemType> pagingController;

  /// The delegate for building the UI pieces of scrolling paged listings.
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// The builder for an in-progress listing.
  final LoadingListingBuilder loadingListingBuilder;

  /// The builder for an in-progress listing with a failed request.
  final ErrorListingBuilder errorListingBuilder;

  /// The builder for a completed listing.
  final CompletedListingBuilder completedListingBuilder;

  /// Whether the extent of the first page indicators should be determined by
  /// the contents being viewed.
  ///
  /// If the paged sliver builder does not shrink wrap, then the first page
  /// indicators will expand to the maximum allowed size. If the paged sliver
  /// builder has unbounded constraints, then [shrinkWrapFirstPageIndicators]
  /// must be true.
  ///
  /// Defaults to false.
  final bool shrinkWrapFirstPageIndicators;

  @override
  _PagedSliverBuilderState<PageKeyType, ItemType> createState() =>
      _PagedSliverBuilderState<PageKeyType, ItemType>();
}

class _PagedSliverBuilderState<PageKeyType, ItemType>
    extends State<PagedSliverBuilder<PageKeyType, ItemType>> {
  PagingController<PageKeyType, ItemType> get _pagingController =>
      widget.pagingController;

  PagedChildBuilderDelegate<ItemType> get _builderDelegate =>
      widget.builderDelegate;

  bool get _shrinkWrapFirstPageIndicators =>
      widget.shrinkWrapFirstPageIndicators ?? false;

  WidgetBuilder get _firstPageErrorIndicatorBuilder =>
      _builderDelegate.firstPageErrorIndicatorBuilder ??
      (_) => FirstPageErrorIndicator(
            onTryAgain: _pagingController.refresh,
          );

  WidgetBuilder get _newPageErrorIndicatorBuilder =>
      _builderDelegate.newPageErrorIndicatorBuilder ??
      (_) => NewPageErrorIndicator(
            onTap: _pagingController.retryLastRequest,
          );

  WidgetBuilder get _firstPageProgressIndicatorBuilder =>
      _builderDelegate.firstPageProgressIndicatorBuilder ??
      (_) => FirstPageProgressIndicator();

  WidgetBuilder get _newPageProgressIndicatorBuilder =>
      _builderDelegate.newPageProgressIndicatorBuilder ??
      (_) => const NewPageProgressIndicator();

  WidgetBuilder get _noItemsFoundIndicatorBuilder =>
      _builderDelegate.noItemsFoundIndicatorBuilder ??
      (_) => NoItemsFoundIndicator();

  WidgetBuilder get _noMoreItemsIndicatorBuilder =>
      _builderDelegate.noMoreItemsIndicatorBuilder;

  int get _invisibleItemsThreshold =>
      _pagingController.invisibleItemsThreshold ?? 3;

  int get _itemCount => _pagingController.itemCount;

  bool get _hasNextPage => _pagingController.hasNextPage;

  PageKeyType get _nextKey => _pagingController.nextPageKey;

  /// The index that triggered the last page request.
  ///
  /// Used to avoid duplicate requests on rebuilds.
  int _lastFetchTriggerIndex;

  @override
  void initState() {
    final preloadedItemCount = _pagingController.itemCount ?? 0;
    if (preloadedItemCount == 0) {
      _requestNextPage(0);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      // The SliverPadding is used to avoid changing the topmost item inside a
      // CustomScrollView.
      // https://github.com/flutter/flutter/issues/55170
      SliverPadding(
        padding: const EdgeInsets.all(0),
        sliver: ValueListenableBuilder<PagingState<PageKeyType, ItemType>>(
          valueListenable: _pagingController,
          builder: (context, pagingState, _) {
            switch (pagingState.status) {
              case PagingStatus.ongoing:
                return widget.loadingListingBuilder(
                  context,
                  _buildListItemWidget,
                  _itemCount,
                  _newPageProgressIndicatorBuilder,
                );
              case PagingStatus.completed:
                return widget.completedListingBuilder(
                  context,
                  _buildListItemWidget,
                  _itemCount,
                  _noMoreItemsIndicatorBuilder,
                );
              case PagingStatus.loadingFirstPage:
                _lastFetchTriggerIndex = null;
                return _FirstPageStatusIndicatorBuilder(
                  builder: _firstPageProgressIndicatorBuilder,
                  shrinkWrap: _shrinkWrapFirstPageIndicators,
                );
              case PagingStatus.subsequentPageError:
                return widget.errorListingBuilder(
                  context,
                  _buildListItemWidget,
                  _itemCount,
                  (context) => _newPageErrorIndicatorBuilder(context),
                );
              case PagingStatus.noItemsFound:
                return _FirstPageStatusIndicatorBuilder(
                  builder: _noItemsFoundIndicatorBuilder,
                  shrinkWrap: _shrinkWrapFirstPageIndicators,
                );
              default:
                return _FirstPageStatusIndicatorBuilder(
                  builder: _firstPageErrorIndicatorBuilder,
                  shrinkWrap: _shrinkWrapFirstPageIndicators,
                );
            }
          },
        ),
      );

  /// Connects the [_pagingController] with the [_builderDelegate] in order to
  /// create a list item widget and request more items if needed.
  Widget _buildListItemWidget(
    BuildContext context,
    int index,
  ) {
    final item = _pagingController.itemList[index];

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

  /// Requests a new page from the controller's listeners.
  void _requestNextPage(int triggerIndex) {
    _lastFetchTriggerIndex = triggerIndex;
    _pagingController.notifyPageRequestListeners(_nextKey);
  }
}

extension on PagingController {
  /// The loaded items count.
  int get itemCount => itemList?.length;

  /// Tells whether there's a next page to fetch.
  bool get hasNextPage => nextPageKey != null;
}

class _FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const _FirstPageStatusIndicatorBuilder({
    @required this.builder,
    this.shrinkWrap = false,
    Key key,
  })  : assert(builder != null),
        assert(shrinkWrap != null),
        super(key: key);

  final WidgetBuilder builder;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return SliverToBoxAdapter(
        child: builder(context),
      );
    } else {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: builder(context),
      );
    }
  }
}
