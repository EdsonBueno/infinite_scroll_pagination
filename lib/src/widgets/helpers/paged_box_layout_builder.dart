import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/paged_layout_builder.dart';

/// TODO
class PagedBoxLayoutBuilder<PageKeyType, ItemType> extends StatelessWidget {
  const PagedBoxLayoutBuilder({
    required this.pagingController,
    required this.builderDelegate,
    required this.loadingListingBuilder,
    required this.errorListingBuilder,
    required this.completedListingBuilder,
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

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, ItemType>(
        pagingController: pagingController,
        builderDelegate: builderDelegate,
        loadingListingBuilder: loadingListingBuilder,
        errorListingBuilder: errorListingBuilder,
        completedListingBuilder: completedListingBuilder,
        // TODO: Does ViewPortBuilder makes more sense?
        layoutBuilder: (context, child) {
          if (builderDelegate.animateTransitions) {
            return AnimatedSwitcher(
              duration: builderDelegate.transitionDuration,
              child: child,
            );
          } else {
            return child;
          }
        },
      );
}
