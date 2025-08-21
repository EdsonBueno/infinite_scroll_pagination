import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/base/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/extensions.dart';

import 'package:infinite_scroll_pagination/src/defaults/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/defaults/no_items_found_indicator.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/core/paging_status.dart';
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
class PagedLayoutBuilder<PageKeyType, ItemType> extends StatefulWidget {
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

class _PagedLayoutBuilderState<PageKeyType, ItemType>
    extends State<PagedLayoutBuilder<PageKeyType, ItemType>> {
  PagingState<PageKeyType, ItemType> get _state => widget.state;

  NextPageCallback get _fetchNextPage =>
      // We make sure to only schedule the fetch after the current build is done.
      // This is important to prevent recursive builds.
      () => WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            widget.fetchNextPage();
          });

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
    final PagingState(:status, :items, :hasNextPage) = _state;
    final int itemCount = items?.length ?? 0;
    return _PagedLayoutAnimator(
      animateTransitions: _builderDelegate.animateTransitions,
      transitionDuration: _builderDelegate.transitionDuration,
      layoutProtocol: _layoutProtocol,
      child: switch (status) {
        PagingStatus.loadingFirstPage => _FirstPageStatusIndicatorBuilder(
            key: const ValueKey(PagingStatus.loadingFirstPage),
            builder: _firstPageProgressIndicatorBuilder,
            shrinkWrap: _shrinkWrapFirstPageIndicators,
            layoutProtocol: _layoutProtocol,
          ),
        PagingStatus.firstPageError => _FirstPageStatusIndicatorBuilder(
            key: const ValueKey(PagingStatus.firstPageError),
            builder: _firstPageErrorIndicatorBuilder,
            shrinkWrap: _shrinkWrapFirstPageIndicators,
            layoutProtocol: _layoutProtocol,
          ),
        PagingStatus.noItemsFound => _FirstPageStatusIndicatorBuilder(
            key: const ValueKey(PagingStatus.noItemsFound),
            builder: _noItemsFoundIndicatorBuilder,
            shrinkWrap: _shrinkWrapFirstPageIndicators,
            layoutProtocol: _layoutProtocol,
          ),
        PagingStatus.ongoing => widget.loadingListingBuilder(
            context,
            (context, index) => _buildListItemWidget(
              context,
              index,
              items!,
              hasNextPage,
            ),
            itemCount,
            _newPageProgressIndicatorBuilder,
          ),
        PagingStatus.subsequentPageError => widget.errorListingBuilder(
            context,
            (context, index) => _buildListItemWidget(
              context,
              index,
              items!,
              hasNextPage,
            ),
            itemCount,
            (context) => _newPageErrorIndicatorBuilder(context),
          ),
        PagingStatus.completed => widget.completedListingBuilder(
            context,
            (context, index) => _buildListItemWidget(
              context,
              index,
              items!,
              hasNextPage,
            ),
            itemCount,
            _noMoreItemsIndicatorBuilder,
          ),
      },
    );
  }

  /// Connects the [_pagingController] with the [_builderDelegate] in order to
  /// create a list item widget and request more items if needed.
  Widget _buildListItemWidget(
    BuildContext context,
    int index,
    List<ItemType> itemList,
    bool hasNextPage,
  ) {
    if (!_hasRequestedNextPage) {
      final maxIndex = max(0, itemList.length - 1);
      final triggerIndex = max(0, maxIndex - _invisibleItemsThreshold);

      // It is important to check whether we are past the trigger, not just at it.
      // This is because otherwise, large tresholds will place the trigger behind the user,
      // Leading to the refresh never being triggered.
      // This behaviour is okay because we make sure not to excessively request pages.
      final hasPassedTrigger = index >= triggerIndex;

      if (hasNextPage && hasPassedTrigger) {
        _hasRequestedNextPage = true;
        _fetchNextPage();
      }
    }

    final item = itemList[index];
    return _builderDelegate.itemBuilder(context, item, index);
  }
}

class _PagedLayoutAnimator extends StatelessWidget {
  const _PagedLayoutAnimator({
    required this.child,
    required this.animateTransitions,
    required this.transitionDuration,
    required this.layoutProtocol,
  });

  final Widget child;
  final bool animateTransitions;
  final Duration transitionDuration;
  final PagedLayoutProtocol layoutProtocol;

  @override
  Widget build(BuildContext context) {
    if (!animateTransitions) return child;
    return switch (layoutProtocol) {
      PagedLayoutProtocol.sliver => SliverAnimatedSwitcher(
          duration: transitionDuration,
          child: child,
        ),
      PagedLayoutProtocol.box => AnimatedSwitcher(
          duration: transitionDuration,
          child: child,
        ),
    };
  }
}

class _FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const _FirstPageStatusIndicatorBuilder({
    super.key,
    required this.builder,
    required this.layoutProtocol,
    this.shrinkWrap = false,
  });

  final WidgetBuilder builder;
  final bool shrinkWrap;
  final PagedLayoutProtocol layoutProtocol;

  @override
  Widget build(BuildContext context) {
    return switch (layoutProtocol) {
      PagedLayoutProtocol.sliver => shrinkWrap
          ? SliverToBoxAdapter(child: builder(context))
          : SliverFillRemaining(
              hasScrollBody: false,
              child: builder(context),
            ),
      PagedLayoutProtocol.box =>
        shrinkWrap ? builder(context) : Center(child: builder(context)),
    };
  }
}
