import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/utils/appended_sliver_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/widgets/layouts/paged_grid_view.dart';
import 'package:sliver_tools/sliver_tools.dart';

typedef SliverGridBuilder = SliverWithKeepAliveWidget Function(
  int childCount,
  SliverChildDelegate delegate,
);

/// Paged [SliverGrid] with progress and error indicators displayed as the last
/// item.
///
/// Similar to [PagedGridView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged grid.
class PagedSliverGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverGrid({
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    Key? key,
  }) : super(key: key);

  /// Matches [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

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
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        completedListingBuilder: (
          context,
          itemBuilder,
          itemCount,
          noMoreItemsIndicatorBuilder,
        ) =>
            _AppendedSliverGrid(
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
            _AppendedSliverGrid(
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
            _AppendedSliverGrid(
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

class _AppendedSliverGrid extends StatelessWidget {
  const _AppendedSliverGrid({
    required this.itemBuilder,
    required this.itemCount,
    required this.sliverGridBuilder,
    this.showAppendixAsGridChild = true,
    this.appendixBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    Key? key,
  }) : super(key: key);

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final SliverGridBuilder sliverGridBuilder;
  final bool showAppendixAsGridChild;
  final WidgetBuilder? appendixBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  @override
  Widget build(BuildContext context) {
    final appendixBuilder = this.appendixBuilder;

    if (showAppendixAsGridChild == true || appendixBuilder == null) {
      return sliverGridBuilder(
        itemCount + (appendixBuilder == null ? 0 : 1),
        _buildSliverDelegate(
          appendixBuilder: appendixBuilder,
        ),
      );
    } else {
      return MultiSliver(
        children: [
          sliverGridBuilder(
            itemCount,
            _buildSliverDelegate(),
          ),
          SliverToBoxAdapter(
            child: appendixBuilder(context),
          ),
        ],
      );
    }
  }

  SliverChildBuilderDelegate _buildSliverDelegate({
    WidgetBuilder? appendixBuilder,
  }) =>
      AppendedSliverChildBuilderDelegate(
        builder: itemBuilder,
        childCount: itemCount,
        appendixBuilder: appendixBuilder,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
}
