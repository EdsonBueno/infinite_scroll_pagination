import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/base/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/helpers/appended_sliver_grid.dart';
import 'package:infinite_scroll_pagination/src/base/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/layouts/paged_grid_view.dart';

/// Paged [SliverGrid] with progress and error indicators displayed as the last
/// item.
///
/// Similar to [PagedGridView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged grid.
class PagedSliverGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverGrid({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
  });

  /// Matches [PagedLayoutBuilder.state].
  final PagingState<PageKeyType, ItemType> state;

  /// Matches [PagedLayoutBuilder.fetchNextPage].
  final NextPageCallback fetchNextPage;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Whether the new page progress indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Whether the new page error indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Whether the no more items indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, ItemType>(
        layoutProtocol: PagedLayoutProtocol.sliver,
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: builderDelegate,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            AppendedSliverGrid(
          sliverGridBuilder: (_, delegate) => SliverGrid(
            delegate: delegate,
            gridDelegate: gridDelegate,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: noMoreItemsIndicatorBuilder,
          showAppendixAsGridChild: showNoMoreItemsIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        loadingListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          progressIndicatorBuilder,
        ) =>
            AppendedSliverGrid(
          sliverGridBuilder: (_, delegate) => SliverGrid(
            delegate: delegate,
            gridDelegate: gridDelegate,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: progressIndicatorBuilder,
          showAppendixAsGridChild: showNewPageProgressIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        errorListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          errorIndicatorBuilder,
        ) =>
            AppendedSliverGrid(
          sliverGridBuilder: (_, delegate) => SliverGrid(
            delegate: delegate,
            gridDelegate: gridDelegate,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: errorIndicatorBuilder,
          showAppendixAsGridChild: showNewPageErrorIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      );
}
