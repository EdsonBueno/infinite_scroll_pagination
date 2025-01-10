import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/base/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/base/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/helpers/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/src/layouts/paged_sliver_masonry_grid.dart';

/// A [MasonryGridView] with pagination capabilities.
///
/// You can also see this as a [PagedGridView] that supports rows of varying
/// sizes.
///
/// This is a wrapper around the [MasonryGridView]
/// from the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) package.
/// For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedMasonryGridView<PageKeyType extends Object, ItemType extends Object>
    extends BoxScrollView {
  const PagedMasonryGridView({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    // Matches [ScrollView.scrollDirection].
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    super.key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          controller: scrollController,
        );

  /// Equivalent to [MasonryGridView.count].
  PagedMasonryGridView.count({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required int crossAxisCount,
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    super.key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                )),
        super(
          controller: scrollController,
        );

  /// Equivalent to [MasonryGridView.extent].
  PagedMasonryGridView.extent({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    super.key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                )),
        super(
          controller: scrollController,
        );

  /// Matches [PagedLayoutBuilder.state].
  final PagingState<PageKeyType, ItemType> state;

  /// Matches [PagedLayoutBuilder.onPageRequest].
  final NextPageCallback fetchNextPage;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Provides the adjusted child count (based on the pagination status) so
  /// that a [SliverSimpleGridDelegate] can be returned.
  final SliverSimpleGridDelegateBuilder gridDelegateBuilder;

  /// Matches [ScrollView.controller]
  final ScrollController? scrollController;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PagedSliverGrid.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  @override
  Widget buildChildLayout(BuildContext context) =>
      PagedSliverMasonryGrid<PageKeyType, ItemType>(
        builderDelegate: builderDelegate,
        state: state,
        fetchNextPage: fetchNextPage,
        gridDelegateBuilder: gridDelegateBuilder,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        showNewPageProgressIndicatorAsGridChild:
            showNewPageProgressIndicatorAsGridChild,
        showNewPageErrorIndicatorAsGridChild:
            showNewPageErrorIndicatorAsGridChild,
        showNoMoreItemsIndicatorAsGridChild:
            showNoMoreItemsIndicatorAsGridChild,
        shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
      );
}
