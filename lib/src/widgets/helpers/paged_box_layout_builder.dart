import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/model/paging_status.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';

/// TODO
class PagedBoxLayoutBuilder<PageKeyType, ItemType> extends StatelessWidget {
  const PagedBoxLayoutBuilder({
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
      // TODO: Se StreamBuilder recebe Stream e Builder. Esse deveria ser
      // PagingController builder? Ou só PagingBuilder? O problema é que além
      // de "reagir" (i.e., buildar) ele também interage chamando listeners.
      PagedLayoutBuilder<PageKeyType, ItemType>(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        loadingListingBuilder: loadingListingBuilder,
        errorListingBuilder: errorListingBuilder,
        completedListingBuilder: completedListingBuilder,
        // TODO: Does ViewPortBuilder makes more sense?
        layoutBuilder: (context, child) {
          final wrappedChild =
              pagingController.value.status.isFirstPageStatusIndicator
                  ? _FirstPageStatusIndicatorBuilder(
                      shrinkWrap: shrinkWrapFirstPageIndicators,
                      child: child,
                    )
                  : child;

          if (builderDelegate.animateTransitions) {
            return AnimatedSwitcher(
              duration: builderDelegate.transitionDuration,
              child: child,
            );
          } else {
            return wrappedChild;
          }
        },
      );
}

extension on PagingStatus {
  bool get isFirstPageStatusIndicator =>
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
      return child;
    } else {
      return Center(
        child: child,
      );
    }
  }
}
