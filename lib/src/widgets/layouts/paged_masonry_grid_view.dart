import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/utils/appended_sliver_child_builder_delegate.dart';

typedef SliverSimpleGridDelegateBuilder = SliverSimpleGridDelegate Function(
  int childCount,
);

/// A [MasonryGridView] with pagination capabilities.
///
/// You can also see this as a [PagedGridView] that supports rows of varying
/// sizes.
///
/// This is a wrapper around the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)
/// package. For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedMasonryGridView<PageKeyType, ItemType> extends StatelessWidget {
  const PagedMasonryGridView({
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.padding,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    Key? key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          key: key,
        );

  /// Equivalent to [MasonryGridView.count].
  PagedMasonryGridView.count({
    required this.pagingController,
    required this.builderDelegate,
    required int crossAxisCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.padding,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
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
        );

  /// Equivalent to [MasonryGridView.extent].
  PagedMasonryGridView.extent({
    required this.pagingController,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.padding,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
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
        );

  /// Matches [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Provides the adjusted child count (based on the pagination status) so
  /// that a [SliverSimpleGridDelegate] can be returned.
  final SliverSimpleGridDelegateBuilder gridDelegateBuilder;

  /// Matches [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// Matches [ScrollView.reverse]
  final bool reverse;

  /// Matches [ScrollView.controller]
  final ScrollController? scrollController;

  /// Matches [ScrollView.primary].
  final bool? primary;

  /// Matches [ScrollView.physics].
  final ScrollPhysics? physics;

  /// Matches [BoxScrollView.padding].
  final EdgeInsetsGeometry? padding;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  /// Matches [ScrollView.cacheExtent].
  final double? cacheExtent;

  /// Matches [ScrollView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// Matches [ScrollView.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Matches [ScrollView.restorationId].
  final String? restorationId;

  /// Matches [ScrollView.clipBehavior].
  final Clip clipBehavior;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PagedSliverGrid.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, ItemType>(
        layoutProtocol: PagedLayoutProtocol.box,
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            MasonryGridView.custom(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          gridDelegate: gridDelegateBuilder(
            itemCount + (noMoreItemsIndicatorBuilder == null ? 0 : 1),
          ),
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
            MasonryGridView.custom(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          gridDelegate: gridDelegateBuilder(
            itemCount + 1,
          ),
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
            MasonryGridView.custom(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          gridDelegate: gridDelegateBuilder(
            itemCount + 1,
          ),
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
