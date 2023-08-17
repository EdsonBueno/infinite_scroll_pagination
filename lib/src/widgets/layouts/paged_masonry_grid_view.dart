import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// A [MasonryGridView] with pagination capabilities.
///
/// You can also see this as a [PagedGridView] that supports rows of varying
/// sizes.
///
/// This is a wrapper around the [MasonryGridView]
/// from the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) package.
/// For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedMasonryGridView<PageKeyType, ItemType> extends BoxScrollView {
  const PagedMasonryGridView({
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    // Matches [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Matches [ScrollView.reverse].
    bool reverse = false,
    // Matches [ScrollView.primary].
    bool? primary,
    // Matches [ScrollView.physics].
    ScrollPhysics? physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
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
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Matches [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
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

  /// Equivalent to [MasonryGridView.count].
  PagedMasonryGridView.count({
    required this.pagingController,
    required this.builderDelegate,
    required int crossAxisCount,
    Axis scrollDirection = Axis.vertical,
    // Matches [ScrollView.reverse].
    bool reverse = false,
    // Matches [ScrollView.primary].
    bool? primary,
    // Matches [ScrollView.physics].
    ScrollPhysics? physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
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
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Matches [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    Key? key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
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

  /// Equivalent to [MasonryGridView.extent].
  PagedMasonryGridView.extent({
    required this.pagingController,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    Axis scrollDirection = Axis.vertical,
    // Matches [ScrollView.reverse].
    bool reverse = false,
    // Matches [ScrollView.primary].
    bool? primary,
    // Matches [ScrollView.physics].
    ScrollPhysics? physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
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
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Matches [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    Key? key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
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
      PagedMasonrySliverGrid<PageKeyType, ItemType>(
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
