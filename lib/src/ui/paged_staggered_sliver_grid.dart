import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_grid_builder.dart';

typedef SliverStaggeredGridDelegateBuilder = SliverStaggeredGridDelegate
    Function(
  int childCount,
);

/// TODO: Document
class PagedStaggeredSliverGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedStaggeredSliverGrid({
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    Key? key,
  }) : super(key: key);

  /// TODO: Document
  PagedStaggeredSliverGrid.count({
    required this.pagingController,
    required this.builderDelegate,
    required int crossAxisCount,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    Key? key,
  })  : gridDelegateBuilder =
            ((childCount) => SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  staggeredTileBuilder: staggeredTileBuilder,
                  staggeredTileCount: childCount,
                )),
        super(key: key);

  /// TODO: Document
  PagedStaggeredSliverGrid.extent({
    required this.pagingController,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    Key? key,
  })  : gridDelegateBuilder =
            ((childCount) => SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  staggeredTileBuilder: staggeredTileBuilder,
                  staggeredTileCount: childCount,
                )),
        super(key: key);

  /// Corresponds to [PagedSliverBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Corresponds to [PagedSliverBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// TODO document.
  final SliverStaggeredGridDelegateBuilder gridDelegateBuilder;

  /// Corresponds to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Corresponds to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Corresponds to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Corresponds to [PagedSliverGridBuilder.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Corresponds to [PagedSliverGridBuilder.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Corresponds to [PagedSliverGridBuilder.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Corresponds to [PagedSliverBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      PagedSliverGridBuilder<PageKeyType, ItemType>(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        sliverGridBuilder: (childCount, delegate) => SliverStaggeredGrid(
          delegate: delegate,
          gridDelegate: gridDelegateBuilder(childCount),
          // Hardcoding [addAutomaticKeepAlives] to false is a workaround for:
          // https://github.com/letsar/flutter_staggered_grid_view/issues/189
          addAutomaticKeepAlives: false,
        ),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        showNewPageProgressIndicatorAsGridChild:
            showNewPageProgressIndicatorAsGridChild,
        showNewPageErrorIndicatorAsGridChild:
            showNewPageErrorIndicatorAsGridChild,
        showNoMoreItemsIndicatorAsGridChild:
            showNoMoreItemsIndicatorAsGridChild,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      );
}
