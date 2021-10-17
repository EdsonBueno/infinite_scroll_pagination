import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/widgets/layouts/paged_sliver_grid.dart';
import 'package:infinite_scroll_pagination/src/widgets/layouts/paged_staggered_sliver_grid.dart';

/// A [StaggeredGridView] with pagination capabilities.
///
/// You can also see this as a [PagedGridView] that supports rows of varying
/// sizes.
///
/// This is a wrapper around the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)
/// package. For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedStaggeredGridView<PageKeyType, ItemType> extends BoxScrollView {
  const PagedStaggeredGridView({
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    // Matches [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Matches [ScrollView.reverse].
    bool reverse = false,
    // Matches [ScrollView.primary].
    bool? primary,
    // Matches [ScrollView.physics].
    ScrollPhysics? physics,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Matches [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent].
    double? cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Matches [ScrollView.keyboardDismissBehavior].
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Matches [ScrollView.restorationId].
    String? restorationId,
    // Matches [ScrollView.clipBehavior].
    Clip clipBehavior = Clip.hardEdge,
    Key? key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
        );

  /// Equivalent to [StaggeredGridView.countBuilder].
  PagedStaggeredGridView.count({
    required this.pagingController,
    required this.builderDelegate,
    required int crossAxisCount,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    // Matches [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Matches [ScrollView.reverse].
    bool reverse = false,
    // Matches [ScrollView.primary].
    bool? primary,
    // Matches [ScrollView.physics].
    ScrollPhysics? physics,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Matches [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent].
    double? cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Matches [ScrollView.keyboardDismissBehavior].
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Matches [ScrollView.restorationId].
    String? restorationId,
    // Matches [ScrollView.clipBehavior].
    Clip clipBehavior = Clip.hardEdge,
    Key? key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  staggeredTileBuilder: staggeredTileBuilder,
                  staggeredTileCount: childCount,
                )),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
        );

  /// Equivalent to [StaggeredGridView.extentBuilder].
  PagedStaggeredGridView.extent({
    required this.pagingController,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    // Matches [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Matches [ScrollView.reverse].
    bool reverse = false,
    // Matches [ScrollView.primary].
    bool? primary,
    // Matches [ScrollView.physics].
    ScrollPhysics? physics,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Matches [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent].
    double? cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Matches [ScrollView.keyboardDismissBehavior].
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Matches [ScrollView.restorationId].
    String? restorationId,
    // Matches [ScrollView.clipBehavior].
    Clip clipBehavior = Clip.hardEdge,
    Key? key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  staggeredTileBuilder: staggeredTileBuilder,
                  staggeredTileCount: childCount,
                )),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
        );

  /// Matches [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [PagedStaggeredSliverGrid.gridDelegateBuilder].
  final SliverStaggeredGridDelegateBuilder gridDelegateBuilder;

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
      PagedStaggeredSliverGrid<PageKeyType, ItemType>(
        builderDelegate: builderDelegate,
        pagingController: pagingController,
        gridDelegateBuilder: gridDelegateBuilder,
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
