import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_grid_view.dart';
import 'package:infinite_scroll_pagination/src/ui/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/utils/appended_sliver_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/workers/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/workers/paged_data_source.dart';

/// Paged [SliverGrid] with progress and error indicators displayed as the last
/// item.
///
/// Similar to [PagedGridView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged grid.
class PagedSliverGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverGrid({
    @required this.dataSource,
    @required this.builderDelegate,
    @required this.gridDelegate,
    this.invisibleItemsThreshold,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    Key key,
  })  : assert(dataSource != null),
        assert(builderDelegate != null),
        assert(gridDelegate != null),
        super(key: key);

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
  Widget build(BuildContext context) =>
      PagedSliverBuilder<PageKeyType, ItemType>(
        dataSource: dataSource,
        builderDelegate: builderDelegate,
        invisibleItemsThreshold: invisibleItemsThreshold,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
        ) =>
            SliverGrid(
          gridDelegate: gridDelegate,
          delegate: _buildSliverDelegate(
            itemBuilder,
            itemCount,
          ),
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            SliverGrid(
          gridDelegate: gridDelegate,
          delegate: _buildSliverDelegate(
            itemBuilder,
            itemCount,
            statusIndicatorBuilder: progressIndicatorBuilder,
          ),
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            SliverGrid(
          gridDelegate: gridDelegate,
          delegate: _buildSliverDelegate(
            itemBuilder,
            itemCount,
            statusIndicatorBuilder: errorIndicatorBuilder,
          ),
        ),
      );

  SliverChildBuilderDelegate _buildSliverDelegate(
    IndexedWidgetBuilder itemBuilder,
    int itemCount, {
    WidgetBuilder statusIndicatorBuilder,
  }) =>
      AppendedSliverChildBuilderDelegate(
        builder: itemBuilder,
        childCount: itemCount,
        appendixBuilder: statusIndicatorBuilder,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
}
