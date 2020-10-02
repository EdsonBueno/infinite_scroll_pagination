import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_list.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';

/// Paged [ListView] with progress and error indicators displayed as the last
/// item.
///
/// To include separators, use [PagedListView.separated].
///
/// Wraps a [PagedSliverList] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [ListView].
class PagedListView<PageKeyType, ItemType> extends BoxScrollView {
  const PagedListView({
    @required this.pagingController,
    @required this.builderDelegate,
    // Corresponds to [ScrollView.controller].
    ScrollController scrollController,
    // Corresponds to [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Corresponds to [ScrollView.reverse].
    bool reverse = false,
    // Corresponds to [ScrollView.primary].
    bool primary,
    // Corresponds to [ScrollView.physics].
    ScrollPhysics physics,
    // Corresponds to [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Corresponds to [BoxScrollView.padding].
    EdgeInsetsGeometry padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Corresponds to [ScrollView.cacheExtent]
    double cacheExtent,
    Key key,
  })  : separatorBuilder = null,
        assert(pagingController != null),
        assert(builderDelegate != null),
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
        );

  const PagedListView.separated({
    @required this.pagingController,
    @required this.builderDelegate,
    @required this.separatorBuilder,
    // Corresponds to [ScrollView.controller].
    ScrollController scrollController,
    // Corresponds to [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Corresponds to [ScrollView.reverse].
    bool reverse = false,
    // Corresponds to [ScrollView.primary].
    bool primary,
    // Corresponds to [ScrollView.physics].
    ScrollPhysics physics,
    // Corresponds to [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Corresponds to [BoxScrollView.padding].
    EdgeInsetsGeometry padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Corresponds to [ScrollView.cacheExtent]
    double cacheExtent,
    Key key,
  })  : assert(pagingController != null),
        assert(builderDelegate != null),
        assert(separatorBuilder != null),
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
        );

  /// Corresponds to [PagedSliverBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Corresponds to [PagedSliverBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// The builder for list item separators, just like in [ListView.separated].
  final IndexedWidgetBuilder separatorBuilder;

  /// Corresponds to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Corresponds to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Corresponds to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Corresponds to [ListView.itemExtent].
  final double itemExtent;

  @override
  Widget buildChildLayout(BuildContext context) => separatorBuilder != null
      ? PagedSliverList<PageKeyType, ItemType>.separated(
          builderDelegate: builderDelegate,
          pagingController: pagingController,
          separatorBuilder: separatorBuilder,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          itemExtent: itemExtent,
        )
      : PagedSliverList<PageKeyType, ItemType>(
          builderDelegate: builderDelegate,
          pagingController: pagingController,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          itemExtent: itemExtent,
        );
}
