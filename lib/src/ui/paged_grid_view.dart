import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_grid.dart';
import 'package:infinite_scroll_pagination/src/workers/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/workers/paged_data_source.dart';

/// Paged [GridView] with progress and error indicators displayed as the last
/// item.
///
/// Wraps a [PagedSliverGrid] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [GridView].
class PagedGridView<PageKeyType, ItemType> extends BoxScrollView {
  const PagedGridView({
    @required this.dataSource,
    @required this.builderDelegate,
    @required this.gridDelegate,
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
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Corresponds to [ScrollView.cacheExtent].
    double cacheExtent,
    Key key,
  })  : assert(dataSource != null),
        assert(builderDelegate != null),
        assert(gridDelegate != null),
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

  /// Corresponds to [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Corresponds to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Corresponds to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Corresponds to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  @override
  Widget buildChildLayout(BuildContext context) =>
      PagedSliverGrid<PageKeyType, ItemType>(
        builderDelegate: builderDelegate,
        dataSource: dataSource,
        gridDelegate: gridDelegate,
        invisibleItemsThreshold: invisibleItemsThreshold,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
}
