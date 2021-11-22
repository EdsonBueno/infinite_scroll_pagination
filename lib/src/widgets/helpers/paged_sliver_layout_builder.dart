import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/model/paging_status.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// TODO
class PagedSliverLayoutBuilder<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverLayoutBuilder({
    required this.pagingController,
    required this.builderDelegate,
    required this.loadingListingBuilder,
    required this.errorListingBuilder,
    required this.completedListingBuilder,
    this.shrinkWrapFirstPageIndicators = false,
    Key? key,
  }) : super(key: key);

  /// TODO
  final PagingController<PageKeyType, ItemType> pagingController;

  /// TODO
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// TODO
  final LoadingListingBuilder loadingListingBuilder;

  /// TODO
  final ErrorListingBuilder errorListingBuilder;

  /// TODO
  final CompletedListingBuilder completedListingBuilder;

  /// Whether the extent of the first page indicators should be determined by
  /// the contents being viewed.
  ///
  /// If the paged layout builder does not shrink wrap, then the first page
  /// indicators will expand to the maximum allowed size. If the paged layout
  /// builder has unbounded constraints, then [shrinkWrapFirstPageIndicators]
  /// must be true.
  ///
  /// Defaults to false.
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) =>
      // TODO: Esse aqui não deve se chamar builder, ele é tipo um listener acho.
      // O problema é que ele de fato mexe com os default indicators e tal.
      PagedLayoutBuilder<PageKeyType, ItemType>(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        loadingListingBuilder: loadingListingBuilder,
        errorListingBuilder: errorListingBuilder,
        completedListingBuilder: completedListingBuilder,
        layoutBuilder: (context, child) {
          final wrappedChild =
              pagingController.value.status.isFirstPageStatus
                  ? _FirstPageStatusIndicatorBuilder(
                      shrinkWrap: shrinkWrapFirstPageIndicators,
                      child: child,
                    )
                  : child;

          if (builderDelegate.animateTransitions) {
            return SliverAnimatedSwitcher(
              duration: builderDelegate.transitionDuration,
              child: wrappedChild,
            );
          } else {
            return wrappedChild;
          }
        },
      );
}

extension on PagingStatus {
  bool get isFirstPageStatus =>
      this == PagingStatus.loadingFirstPage ||
      this == PagingStatus.noItemsFound ||
      this == PagingStatus.firstPageError;
}

class _FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const _FirstPageStatusIndicatorBuilder({
    required this.child,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return SliverToBoxAdapter(
        child: child,
      );
    } else {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: child,
      );
    }
  }
}
