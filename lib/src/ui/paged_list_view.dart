import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_list.dart';

/// Paged [ListView] with progress and error indicators displayed as the last
/// item.
///
/// To include separators, use [PagedListView.separated].
///
/// Wraps a [PagedSliverList] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [ListView].
class PagedListView<PageKeyType, ItemType> extends BoxScrollView {
  const PagedListView({
    required this.pagingController,
    required this.builderDelegate,
    // Corresponds to [ScrollView.controller].
    ScrollController? scrollController,
    // Corresponds to [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Corresponds to [ScrollView.reverse].
    bool reverse = false,
    // Corresponds to [ScrollView.primary].
    bool? primary,
    // Corresponds to [ScrollView.physics].
    ScrollPhysics? physics,
    // Corresponds to [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Corresponds to [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Corresponds to [ScrollView.cacheExtent]
    double? cacheExtent,
    // Corresponds to [ScrollView.dragStartBehavior]
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Corresponds to [ScrollView.keyboardDismissBehavior]
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Corresponds to [ScrollView.restorationId]
    String? restorationId,
    // Corresponds to [ScrollView.clipBehavior]
    Clip clipBehavior = Clip.hardEdge,
    Key? key,
  })  : _separatorBuilder = null,
        _shrinkWrapFirstPageIndicators = shrinkWrap,
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

  const PagedListView.separated({
    required this.pagingController,
    required this.builderDelegate,
    required IndexedWidgetBuilder separatorBuilder,
    // Corresponds to [ScrollView.controller].
    ScrollController? scrollController,
    // Corresponds to [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Corresponds to [ScrollView.reverse].
    bool reverse = false,
    // Corresponds to [ScrollView.primary].
    bool? primary,
    // Corresponds to [ScrollView.physics].
    ScrollPhysics? physics,
    // Corresponds to [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Corresponds to [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Corresponds to [ScrollView.cacheExtent]
    double? cacheExtent,
    // Corresponds to [ScrollView.dragStartBehavior]
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Corresponds to [ScrollView.keyboardDismissBehavior]
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Corresponds to [ScrollView.restorationId]
    String? restorationId,
    // Corresponds to [ScrollView.clipBehavior]
    Clip clipBehavior = Clip.hardEdge,
    Key? key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        _separatorBuilder = separatorBuilder,
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

  /// Corresponds to [PagedSliverBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Corresponds to [PagedSliverBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// The builder for list item separators, just like in [ListView.separated].
  final IndexedWidgetBuilder? _separatorBuilder;

  /// Corresponds to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Corresponds to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Corresponds to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Corresponds to [ListView.itemExtent].
  final double? itemExtent;

  /// Corresponds to [PagedSliverList.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  @override
  Widget buildChildLayout(BuildContext context) {
    final separatorBuilder = _separatorBuilder;
    return separatorBuilder != null
        ? PagedSliverList<PageKeyType, ItemType>.separated(
            builderDelegate: builderDelegate,
            pagingController: pagingController,
            separatorBuilder: separatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            itemExtent: itemExtent,
            shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
          )
        : PagedSliverList<PageKeyType, ItemType>(
            builderDelegate: builderDelegate,
            pagingController: pagingController,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            itemExtent: itemExtent,
            shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
          );
  }
}
