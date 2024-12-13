import 'package:flutter/widgets.dart';

import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/base/paged_layout_builder.dart';

class PagingListener<PageKeyType extends Object, ItemType extends Object>
    extends StatelessWidget {
  const PagingListener({
    super.key,
    required this.controller,
    required this.builder,
  });

  final PagingController<PageKeyType, ItemType> controller;
  final Widget Function(
    BuildContext context,
    PagingState<PageKeyType, ItemType> state,
    NextPageCallback fetchNextPage,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PagingState<PageKeyType, ItemType>>(
      valueListenable: controller,
      builder: (context, state, _) => builder(
        context,
        state,
        controller.fetchNextPage,
      ),
    );
  }
}
