import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/utils/appended_sliver_child_builder_delegate.dart';

/// Paged [PageView] with progress and error indicators displayed as the last
/// item.
///
/// Similar to a [PageView].
/// Useful for combining another paged widget with a page view with details.
class PagedPageView<PageKeyType, ItemType> extends StatelessWidget {
  const PagedPageView({
    required this.pagingController,
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
    this.shrinkWrapFirstPageIndicators = false,
    Key? key,
  }) : super(key: key);

  /// Corresponds to [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Corresponds to [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Corresponds to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Corresponds to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Corresponds to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Corresponds to [PageView.allowImplicitScrolling].
  final bool allowImplicitScrolling;

  /// Corresponds to [PageView.restorationId].
  final String? restorationId;

  /// Corresponds to [PageView.controller].
  final PageController? pageController;

  /// Corresponds to [PageView.scrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// Corresponds to [PageView.scrollDirection].
  final Axis scrollDirection;

  /// Corresponds to [PageView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// Corresponds to [PageView.clipBehavior].
  final Clip clipBehavior;

  /// Corresponds to [PageView.reverse].
  final bool reverse;

  /// Corresponds to [PageView.physics].
  final ScrollPhysics? physics;

  /// Corresponds to [PageView.pageSnapping].
  final bool pageSnapping;

  /// Corresponds to [PageView.onPageChanged].
  final void Function(int)? onPageChanged;

  /// Corresponds to [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, ItemType>(
        layoutProtocol: LayoutProtocol.box,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            _AppendedPageView(
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: noMoreItemsIndicatorBuilder,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          restorationId: restorationId,
          pageController: pageController,
          onPageChanged: onPageChanged,
          scrollBehavior: scrollBehavior,
          scrollDirection: scrollDirection,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          allowImplicitScrolling: allowImplicitScrolling,
          reverse: reverse,
          physics: physics,
          pageSnapping: pageSnapping,
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            _AppendedPageView(
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: progressIndicatorBuilder,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          restorationId: restorationId,
          pageController: pageController,
          onPageChanged: onPageChanged,
          scrollBehavior: scrollBehavior,
          scrollDirection: scrollDirection,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          allowImplicitScrolling: allowImplicitScrolling,
          reverse: reverse,
          physics: physics,
          pageSnapping: pageSnapping,
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            _AppendedPageView(
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: errorIndicatorBuilder,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          restorationId: restorationId,
          pageController: pageController,
          onPageChanged: onPageChanged,
          scrollBehavior: scrollBehavior,
          scrollDirection: scrollDirection,
          dragStartBehavior: dragStartBehavior,
          clipBehavior: clipBehavior,
          allowImplicitScrolling: allowImplicitScrolling,
          reverse: reverse,
          physics: physics,
          pageSnapping: pageSnapping,
        ),
      );
}

class _AppendedPageView extends PageView {
  _AppendedPageView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    WidgetBuilder? appendixBuilder,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    // Corresponds to [PageView.allowImplicitScrolling].
    bool allowImplicitScrolling = false,
    // Corresponds to [PageView.restorationId].
    String? restorationId,
    // Corresponds to [PageView.pageController].
    PageController? pageController,
    // Corresponds to [PageView.scrollBehavior].
    ScrollBehavior? scrollBehavior,
    // Corresponds to [PageView.scrollDirection].
    Axis scrollDirection = Axis.horizontal,
    // Corresponds to [PageView.dragStartBehavior].
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Corresponds to [PageView.clipBehavior].
    Clip clipBehavior = Clip.hardEdge,
    // Corresponds to [PageView.reverse].
    bool reverse = false,
    // Corresponds to [PageView.physics].
    ScrollPhysics? physics,
    // Corresponds to [PageView.pageSnapping].
    bool pageSnapping = true,
    // Corresponds to [PageView.onPageChanged].
    void Function(int)? onPageChanged,
    Key? key,
  }) : super.custom(
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
          childrenDelegate: AppendedSliverChildBuilderDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: appendixBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        );
}
