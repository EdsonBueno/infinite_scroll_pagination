import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/paged_data_source.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/paged_sliver_list.dart';

/// Paged [ListView] with progress and error indicators displayed as the last
/// item.
///
/// To include separators, use [PagedListView.separated].
///
/// Wraps a [PagedSliverList] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [ListView].
class PagedListView<PageKeyType, ItemType> extends BoxScrollView {
  const PagedListView({
    @required this.dataSource,
    @required this.builderDelegate,
    this.invisibleItemsThreshold,
    // Corresponds to [ScrollView.controller].
    ScrollController controller,
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
        assert(dataSource != null),
        assert(builderDelegate != null),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
        );

  const PagedListView.separated({
    @required this.dataSource,
    @required this.builderDelegate,
    @required this.separatorBuilder,
    this.invisibleItemsThreshold,
    // Corresponds to [ScrollView.controller].
    ScrollController controller,
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
  })  : assert(dataSource != null),
        assert(builderDelegate != null),
        assert(separatorBuilder != null),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
        );

  /// Corresponds to [PagedSliverBuilder.dataSource].
  final PagedDataSource<PageKeyType, ItemType> dataSource;

  /// Corresponds to [PagedSliverBuilder.invisibleItemsThreshold].
  final int invisibleItemsThreshold;

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
          dataSource: dataSource,
          invisibleItemsThreshold: invisibleItemsThreshold,
          separatorBuilder: separatorBuilder,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          itemExtent: itemExtent,
        )
      : PagedSliverList<PageKeyType, ItemType>(
          builderDelegate: builderDelegate,
          dataSource: dataSource,
          invisibleItemsThreshold: invisibleItemsThreshold,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          itemExtent: itemExtent,
        );
}
