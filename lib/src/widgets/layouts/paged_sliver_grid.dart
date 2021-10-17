import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_sliver_grid_builder.dart';
import 'package:infinite_scroll_pagination/src/widgets/layouts/paged_grid_view.dart';

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

  /// Matches [PagedSliverGridBuilder.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Matches [PagedSliverGridBuilder.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Matches [PagedSliverGridBuilder.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      PagedSliverGridBuilder<PageKeyType, ItemType>(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        builder: (_, delegate) => SliverGrid(
          delegate: delegate,
          gridDelegate: gridDelegate,
        ),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        showNewPageProgressIndicatorAsGridChild:
            showNewPageProgressIndicatorAsGridChild,
        showNewPageErrorIndicatorAsGridChild:
            showNewPageErrorIndicatorAsGridChild,
        showNoMoreItemsIndicatorAsGridChild:
            showNoMoreItemsIndicatorAsGridChild,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      );
}
