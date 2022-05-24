import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_sliver_grid_builder.dart';

typedef SliverStaggeredGridDelegateBuilder = SliverStaggeredGridDelegate
    Function(
  int childCount,
);

/// A [SliverStaggeredGrid] with pagination capabilities.
///
/// You can also see this as a [PagedSliverGrid] that supports rows of varying
/// sizes.
///
/// This is a wrapper around the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)
/// package. For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
///
/// Similar to [PagedStaggeredGridView] but this needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged list.
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

  /// Equivalent to [SliverStaggeredGrid.countBuilder].
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

  /// Equivalent to [SliverStaggeredGrid.extentBuilder].
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

  /// Matches [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Provides the adjusted child count (based on the pagination status) so
  /// that a [SliverStaggeredGridDelegate] can be returned.
  final SliverStaggeredGridDelegateBuilder gridDelegateBuilder;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PagedSliverGridBuilder.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Matches [PagedSliverGridBuilder.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Matches [PagedSliverGridBuilder.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      PagedSliverGridBuilder<PageKeyType, ItemType>(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        builder: (childCount, delegate) => SliverStaggeredGrid(
          delegate: delegate,
          gridDelegate: gridDelegateBuilder(childCount),
          // Hardcoding [addAutomaticKeepAlives] to false is a workaround for
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
