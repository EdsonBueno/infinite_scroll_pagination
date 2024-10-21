import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/model/paging_state.dart';
import 'package:infinite_scroll_pagination/src/model/paging_status.dart';

import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/no_items_found_indicator.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// Called to request a new page of data.
typedef NextPageCallback = VoidCallback;

typedef CompletedListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder? noMoreItemsIndicatorBuilder,
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

/// The Flutter layout protocols supported by [PagedLayoutBuilder].
enum PagedLayoutProtocol { sliver, box }

/// Facilitates creating infinitely scrolled paged layouts.
///
/// Combines a [PagingController] with a
/// [PagedChildBuilderDelegate] and calls the supplied
/// [loadingListingBuilder], [errorListingBuilder] or
/// [completedListingBuilder] for filling in the gaps.
///
/// For ordinary cases, this widget shouldn't be used directly. Instead, take a
/// look at [PagedSliverList], [PagedSliverGrid], [PagedListView],
/// [PagedGridView], [PagedMasonryGridView], or [PagedPageView].
class PagedLayoutBuilder<PageKeyType extends Object, ItemType extends Object>
    extends StatefulWidget {
  const PagedLayoutBuilder({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required this.loadingListingBuilder,
    required this.errorListingBuilder,
    required this.completedListingBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
  });

  /// The paging state for this layout.
  final PagingState<PageKeyType, ItemType> state;

  /// A callback function that is triggered to request a new page of data.
  final NextPageCallback fetchNextPage;

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
  /// If the paged layout builder does not shrink wrap, then the first page
  /// indicators will expand to the maximum allowed size. If the paged layout
  /// builder has unbounded constraints, then [shrinkWrapFirstPageIndicators]
  /// must be true.
  ///
  /// Defaults to false.
  final bool shrinkWrapFirstPageIndicators;

  /// The layout protocol of the widget you're using this to build.
  ///
  /// For example, if [PagedLayoutProtocol.sliver] is specified, then
  /// [loadingListingBuilder], [errorListingBuilder], and
  /// [completedListingBuilder] have to return a Sliver widget.
  final PagedLayoutProtocol layoutProtocol;

  @override
  State<PagedLayoutBuilder<PageKeyType, ItemType>> createState() =>
      _PagedLayoutBuilderState<PageKeyType, ItemType>();
}

class _PagedLayoutBuilderState<PageKeyType extends Object,
        ItemType extends Object>
    extends State<PagedLayoutBuilder<PageKeyType, ItemType>> {
  PagingState<PageKeyType, ItemType> get _state => widget.state;

  NextPageCallback get _fetchNextPage => widget.fetchNextPage;

  PagedChildBuilderDelegate<ItemType> get _builderDelegate =>
      widget.builderDelegate;

  bool get _shrinkWrapFirstPageIndicators =>
      widget.shrinkWrapFirstPageIndicators;

  PagedLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  WidgetBuilder get _firstPageErrorIndicatorBuilder =>
      _builderDelegate.firstPageErrorIndicatorBuilder ??
      (_) => FirstPageErrorIndicator(
            onTryAgain: _fetchNextPage,
          );

  WidgetBuilder get _newPageErrorIndicatorBuilder =>
      _builderDelegate.newPageErrorIndicatorBuilder ??
      (_) => NewPageErrorIndicator(
            onTap: _fetchNextPage,
          );

  WidgetBuilder get _firstPageProgressIndicatorBuilder =>
      _builderDelegate.firstPageProgressIndicatorBuilder ??
      (_) => const FirstPageProgressIndicator();

  WidgetBuilder get _newPageProgressIndicatorBuilder =>
      _builderDelegate.newPageProgressIndicatorBuilder ??
      (_) => const NewPageProgressIndicator();

  WidgetBuilder get _noItemsFoundIndicatorBuilder =>
      _builderDelegate.noItemsFoundIndicatorBuilder ??
      (_) => const NoItemsFoundIndicator();

  WidgetBuilder? get _noMoreItemsIndicatorBuilder =>
      _builderDelegate.noMoreItemsIndicatorBuilder;

  int get _invisibleItemsThreshold => _builderDelegate.invisibleItemsThreshold;

  int get _itemCount => _state.items?.length ?? 0;

  bool get _hasNextPage => _state.hasNextPage;

  /// Avoids duplicate requests on rebuilds.
  bool _hasRequestedNextPage = false;

  @override
  void initState() {
    super.initState();
    if (_state.status == PagingStatus.loadingFirstPage) {
      _fetchNextPage();
    }
  }

  @override
  void didUpdateWidget(
      covariant PagedLayoutBuilder<PageKeyType, ItemType> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      if (_state.status == PagingStatus.loadingFirstPage) {
        _fetchNextPage();
      } else if (_state.status == PagingStatus.ongoing) {
        _hasRequestedNextPage = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final items = _state.items;
    switch (_state.status) {
      case PagingStatus.ongoing:
        child = widget.loadingListingBuilder(
          context,
          // We must create this closure to close over the [itemList]
          // value. That way, we are safe if [itemList] value changes
          // while Flutter rebuilds the widget (due to animations, for
          // example.)
          (context, index) => _buildListItemWidget(
            context,
            index,
            items!,
          ),
          _itemCount,
          _newPageProgressIndicatorBuilder,
        );
        break;
      case PagingStatus.completed:
        child = widget.completedListingBuilder(
          context,
          (context, index) => _buildListItemWidget(
            context,
            index,
            items!,
          ),
          _itemCount,
          _noMoreItemsIndicatorBuilder,
        );
        break;
      case PagingStatus.loadingFirstPage:
        child = _FirstPageStatusIndicatorBuilder(
          builder: _firstPageProgressIndicatorBuilder,
          shrinkWrap: _shrinkWrapFirstPageIndicators,
          layoutProtocol: _layoutProtocol,
        );
        break;
      case PagingStatus.subsequentPageError:
        child = widget.errorListingBuilder(
          context,
          (context, index) => _buildListItemWidget(
            context,
            index,
            items!,
          ),
          _itemCount,
          (context) => _newPageErrorIndicatorBuilder(context),
        );
        break;
      case PagingStatus.noItemsFound:
        child = _FirstPageStatusIndicatorBuilder(
          builder: _noItemsFoundIndicatorBuilder,
          shrinkWrap: _shrinkWrapFirstPageIndicators,
          layoutProtocol: _layoutProtocol,
        );
        break;
      default:
        child = _FirstPageStatusIndicatorBuilder(
          builder: _firstPageErrorIndicatorBuilder,
          shrinkWrap: _shrinkWrapFirstPageIndicators,
          layoutProtocol: _layoutProtocol,
        );
    }

    if (_builderDelegate.animateTransitions) {
      if (_layoutProtocol == PagedLayoutProtocol.sliver) {
        return SliverAnimatedSwitcher(
          duration: _builderDelegate.transitionDuration,
          child: child,
        );
      } else {
        return AnimatedSwitcher(
          duration: _builderDelegate.transitionDuration,
          child: child,
        );
      }
    } else {
      return child;
    }
  }

  /// Connects the [_pagingController] with the [_builderDelegate] in order to
  /// create a list item widget and request more items if needed.
  Widget _buildListItemWidget(
    BuildContext context,
    int index,
    List<ItemType> itemList,
  ) {
    if (!_hasRequestedNextPage) {
      final newPageRequestTriggerIndex =
          max(0, _itemCount - _invisibleItemsThreshold);

      final isBuildingTriggerIndexItem = index == newPageRequestTriggerIndex;

      if (_hasNextPage && isBuildingTriggerIndexItem) {
        // Schedules the request for the end of this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fetchNextPage();
        });
        _hasRequestedNextPage = true;
      }
    }

    final item = itemList[index];
    return _builderDelegate.itemBuilder(context, item, index);
  }
}

class _FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const _FirstPageStatusIndicatorBuilder({
    required this.builder,
    required this.layoutProtocol,
    this.shrinkWrap = false,
  });

  final WidgetBuilder builder;
  final bool shrinkWrap;
  final PagedLayoutProtocol layoutProtocol;

  @override
  Widget build(BuildContext context) {
    if (layoutProtocol == PagedLayoutProtocol.sliver) {
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
    } else {
      if (shrinkWrap) {
        return builder(context);
      } else {
        return Center(
          child: builder(context),
        );
      }
    }
  }
}
