import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/src/core/paged_child_builder_delegate.dart';
import 'package:infinite_scroll_pagination/src/model/paging_state.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';
import 'package:infinite_scroll_pagination/src/widgets/layouts/paged_sliver_grid.dart';

/// A [GridView] with pagination capabilities.
///
/// Wraps a [PagedSliverGrid] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [GridView].
class PagedGridView<PageKeyType extends Object, ItemType extends Object>
    extends BoxScrollView {
  const PagedGridView({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required this.gridDelegate,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    // Matches [ScrollView.scrollDirection].
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    super.key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          controller: scrollController,
        );

  /// Matches [PagedLayoutBuilder.state].
  final PagingState<PageKeyType, ItemType> state;

  /// Matches [PagedLayoutBuilder.onPageRequest].
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

  /// Matches [PagedSliverGrid.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  @override
  Widget buildChildLayout(BuildContext context) =>
      PagedSliverGrid<PageKeyType, ItemType>(
        builderDelegate: builderDelegate,
        state: state,
        fetchNextPage: fetchNextPage,
        gridDelegate: gridDelegate,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        showNewPageProgressIndicatorAsGridChild:
            showNewPageProgressIndicatorAsGridChild,
        showNewPageErrorIndicatorAsGridChild:
            showNewPageErrorIndicatorAsGridChild,
        showNoMoreItemsIndicatorAsGridChild:
            showNoMoreItemsIndicatorAsGridChild,
        shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
      );
}
