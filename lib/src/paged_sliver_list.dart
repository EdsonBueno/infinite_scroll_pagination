import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/appended_sliver_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/paged_data_source.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/paged_sliver_builder.dart';
import 'package:infinite_scroll_pagination/src/paged_list_view.dart';

/// Paged [SliverList] with progress and error indicators displayed as the last
/// item.
///
/// To include separators, use [PagedSliverList.separated].
///
/// Similar to [PagedListView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged list.
class PagedSliverList<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverList({
    @required this.dataSource,
    @required this.builderDelegate,
    this.invisibleItemsThreshold,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.semanticIndexCallback,
    Key key,
  })  : separatorBuilder = null,
        assert(dataSource != null),
        assert(builderDelegate != null),
        super(key: key);

  const PagedSliverList.separated({
    @required this.dataSource,
    @required this.builderDelegate,
    @required this.separatorBuilder,
    this.invisibleItemsThreshold,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.semanticIndexCallback,
    Key key,
  })  : assert(dataSource != null),
        assert(builderDelegate != null),
        assert(separatorBuilder != null),
        super(key: key);

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

  /// Corresponds to [SliverChildBuilderDelegate.semanticIndexCallback].
  final SemanticIndexCallback semanticIndexCallback;

  /// Corresponds to [SliverFixedExtentList.itemExtent].
  final double itemExtent;

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
            _buildSliverList(
          itemBuilder,
          itemCount,
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            _buildSliverList(
          itemBuilder,
          itemCount,
          statusIndicatorBuilder: progressIndicatorBuilder,
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            _buildSliverList(
          itemBuilder,
          itemCount,
          statusIndicatorBuilder: errorIndicatorBuilder,
        ),
      );

  SliverMultiBoxAdaptorWidget _buildSliverList(
    IndexedWidgetBuilder itemBuilder,
    int itemCount, {
    WidgetBuilder statusIndicatorBuilder,
  }) {
    final delegate = _buildSliverDelegate(
      itemBuilder,
      itemCount,
      statusIndicatorBuilder: statusIndicatorBuilder,
    );
    return (itemExtent == null || separatorBuilder != null)
        ? SliverList(
            delegate: delegate,
          )
        : SliverFixedExtentList(
            delegate: delegate,
            itemExtent: itemExtent,
          );
  }

  SliverChildBuilderDelegate _buildSliverDelegate(
    IndexedWidgetBuilder itemBuilder,
    int itemCount, {
    WidgetBuilder statusIndicatorBuilder,
  }) =>
      separatorBuilder == null
          ? AppendedSliverChildBuilderDelegate(
              builder: itemBuilder,
              childCount: itemCount,
              appendixBuilder: statusIndicatorBuilder,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
              addSemanticIndexes: addSemanticIndexes,
              semanticIndexCallback: semanticIndexCallback,
            )
          : AppendedSliverChildBuilderDelegate.separated(
              builder: itemBuilder,
              childCount: itemCount,
              appendixBuilder: statusIndicatorBuilder,
              separatorBuilder: separatorBuilder,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
              addSemanticIndexes: addSemanticIndexes,
            );
}
