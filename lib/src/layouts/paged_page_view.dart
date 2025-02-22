import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/base/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/helpers/appended_sliver_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/base/paged_layout_builder.dart';

/// Paged [PageView] with progress and error indicators displayed as the last
/// item.
///
/// Similar to a [PageView].
/// Useful for combining another paged widget with a page view with details.
class PagedPageView<PageKeyType, ItemType> extends StatelessWidget {
  const PagedPageView({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.pageController,
    this.scrollBehavior,
    this.scrollDirection = Axis.horizontal,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.reverse = false,
    this.physics,
    this.onPageChanged,
    this.pageSnapping = true,
    this.padEnds = true,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
  });

  /// Matches [PagedLayoutBuilder.state].
  final PagingState<PageKeyType, ItemType> state;

  /// Matches [PagedLayoutBuilder.onPageRequest].
  final NextPageCallback fetchNextPage;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PageView.allowImplicitScrolling].
  final bool allowImplicitScrolling;

  /// Matches [PageView.restorationId].
  final String? restorationId;

  /// Matches [PageView.controller].
  final PageController? pageController;

  /// Matches [PageView.scrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// Matches [PageView.scrollDirection].
  final Axis scrollDirection;

  /// Matches [PageView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// Matches [PageView.clipBehavior].
  final Clip clipBehavior;

  /// Matches [PageView.reverse].
  final bool reverse;

  /// Matches [PageView.physics].
  final ScrollPhysics? physics;

  /// Matches [PageView.pageSnapping].
  final bool pageSnapping;

  /// Matches [PageView.onPageChanged].
  final void Function(int)? onPageChanged;

  /// Matches [PageView.padEnds].
  final bool padEnds;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, ItemType>(
        layoutProtocol: PagedLayoutProtocol.box,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            PageView.custom(
          key: key,
          restorationId: restorationId,
          controller: pageController,
          onPageChanged: onPageChanged,
          scrollBehavior: scrollBehavior,
          scrollDirection: scrollDirection,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          allowImplicitScrolling: allowImplicitScrolling,
          reverse: reverse,
          physics: physics,
          pageSnapping: pageSnapping,
          padEnds: padEnds,
          childrenDelegate: AppendedSliverChildBuilderDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: noMoreItemsIndicatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            PageView.custom(
          key: key,
          restorationId: restorationId,
          controller: pageController,
          onPageChanged: onPageChanged,
          scrollBehavior: scrollBehavior,
          scrollDirection: scrollDirection,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          allowImplicitScrolling: allowImplicitScrolling,
          reverse: reverse,
          physics: physics,
          pageSnapping: pageSnapping,
          padEnds: padEnds,
          childrenDelegate: AppendedSliverChildBuilderDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: progressIndicatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            PageView.custom(
          key: key,
          restorationId: restorationId,
          controller: pageController,
          onPageChanged: onPageChanged,
          scrollBehavior: scrollBehavior,
          scrollDirection: scrollDirection,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          allowImplicitScrolling: allowImplicitScrolling,
          reverse: reverse,
          physics: physics,
          pageSnapping: pageSnapping,
          padEnds: padEnds,
          childrenDelegate: AppendedSliverChildBuilderDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: errorIndicatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        ),
      );
}
