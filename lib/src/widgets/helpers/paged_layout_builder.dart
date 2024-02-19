import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/utils/listenable_listener.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/first_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/first_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/new_page_error_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/new_page_progress_indicator.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/no_items_found_indicator.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
    required this.pagingController,
    required this.builderDelegate,
    required this.loadingListingBuilder,
    required this.errorListingBuilder,
    required this.completedListingBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
    Key? key,
  }) : super(key: key);

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
  PagingController<PageKeyType, ItemType> get _pagingController =>
      widget.pagingController;

  PagedChildBuilderDelegate<ItemType> get _builderDelegate =>
      widget.builderDelegate;

  bool get _shrinkWrapFirstPageIndicators =>
      widget.shrinkWrapFirstPageIndicators;

  PagedLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  WidgetBuilder get _firstPageErrorIndicatorBuilder =>
      _builderDelegate.firstPageErrorIndicatorBuilder ??
      (_) => FirstPageErrorIndicator(
            onTryAgain: _pagingController.retryLastFailedRequest,
          );

  WidgetBuilder get _newPageErrorIndicatorBuilder =>
      _builderDelegate.newPageErrorIndicatorBuilder ??
      (_) => NewPageErrorIndicator(
            onTap: _pagingController.retryLastFailedRequest,
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

  int get _invisibleItemsThreshold =>
      _pagingController.invisibleItemsThreshold ?? 3;

  int get _itemCount => _pagingController.itemCount;

  bool get _hasNextPage => _pagingController.hasNextPage;

  PageKeyType? get _nextKey => _pagingController.nextPageKey;

  /// Avoids duplicate requests on rebuilds.
  bool _hasRequestedNextPage = false;

  @override
  Widget build(BuildContext context) => ListenableListener(
        listenable: _pagingController,
        listener: () {
          final status = _pagingController.value.status;

          if (status == PagingStatus.loadingFirstPage) {
            _pagingController.notifyPageRequestListeners(
              _pagingController.firstPageKey,
            );
          }

          if (status == PagingStatus.ongoing) {
            _hasRequestedNextPage = false;
          }
        },
        child: ValueListenableBuilder<PagingState<PageKeyType, ItemType>>(
          valueListenable: _pagingController,
          builder: (context, pagingState, _) {
            Widget child;
            final itemList = _pagingController.itemList;
            switch (pagingState.status) {
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
                    itemList!,
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
                    itemList!,
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
                    itemList!,
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
          },
        ),
      );

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
          _pagingController.notifyPageRequestListeners(_nextKey as PageKeyType);
        });
        _hasRequestedNextPage = true;
      }
    }

    final item = itemList[index];
    return _builderDelegate.itemBuilder(context, item, index);
  }
}

extension on PagingController {
  /// The loaded items count.
  int get itemCount => itemList?.length ?? 0;

  /// Tells whether there's a next page to request.
  bool get hasNextPage => nextPageKey != null;
}

class _FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const _FirstPageStatusIndicatorBuilder({
    required this.builder,
    required this.layoutProtocol,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key);

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
