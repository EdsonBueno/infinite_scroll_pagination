import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/base/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/helpers/appended_sliver_grid.dart';
import 'package:infinite_scroll_pagination/src/base/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/helpers/flutter_staggered_grid_view.dart';

/// A [SliverAlignedGrid] with pagination capabilities.
///
/// You can also see this as a [PagedSliverGrid] that ensures that the items
/// in its rows all have the same size.
///
/// This is a wrapper around the [SliverAlignedGrid]
/// from the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) package.
/// For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedSliverAlignedGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverAlignedGrid({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
  });

  PagedSliverAlignedGrid.count({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required int crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
  }) : gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                ));

  PagedSliverAlignedGrid.extent({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
  }) : gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                ));

  /// Matches [PagedLayoutBuilder.state].
  final PagingState<PageKeyType, ItemType> state;

  /// Matches [PagedLayoutBuilder.fetchNextPage].
  final NextPageCallback fetchNextPage;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Provides the adjusted child count (based on the pagination status) so
  /// that a [SliverSimpleGridDelegate] can be returned.
  final SliverSimpleGridDelegateBuilder gridDelegateBuilder;

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

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  /// Matches [SliverAlignedGrid.mainAxisSpacing].
  final double mainAxisSpacing;

  /// Matches [SliverAlignedGrid.crossAxisSpacing].
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, ItemType>(
        layoutProtocol: PagedLayoutProtocol.sliver,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: builderDelegate,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            AppendedSliverGrid(
          sliverGridBuilder: (childCount, delegate) => SliverAlignedGrid(
            itemBuilder: delegate.build,
            itemCount: childCount,
            gridDelegate: gridDelegateBuilder(childCount),
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: noMoreItemsIndicatorBuilder,
          showAppendixAsGridChild: showNoMoreItemsIndicatorAsGridChild,
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
          addRepaintBoundaries: false,
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            AppendedSliverGrid(
          sliverGridBuilder: (childCount, delegate) => SliverAlignedGrid(
            itemBuilder: delegate.build,
            itemCount: childCount,
            gridDelegate: gridDelegateBuilder(childCount),
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: progressIndicatorBuilder,
          showAppendixAsGridChild: showNewPageProgressIndicatorAsGridChild,
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
          addRepaintBoundaries: false,
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            AppendedSliverGrid(
          sliverGridBuilder: (childCount, delegate) => SliverAlignedGrid(
            itemBuilder: delegate.build,
            itemCount: childCount,
            gridDelegate: gridDelegateBuilder(childCount),
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: errorIndicatorBuilder,
          showAppendixAsGridChild: showNewPageErrorIndicatorAsGridChild,
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
          addRepaintBoundaries: false,
        ),
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      );
}
