import 'package:flutter/widgets.dart';

import 'appended_sliver_child_builder_delegate.dart';

/// Usually returns a SliverWithKeepAliveWidget
typedef SliverGridBuilder = Widget Function(
  int childCount,
  SliverChildDelegate delegate,
);

class AppendedSliverGrid extends StatelessWidget {
  const AppendedSliverGrid({
    required this.itemBuilder,
    required this.itemCount,
    required this.sliverGridBuilder,
    this.showAppendixAsGridChild = true,
    this.appendixBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    super.key,
  });

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

    SliverChildBuilderDelegate buildSliverDelegate({
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

    return SliverMainAxisGroup(
      slivers: [
        sliverGridBuilder(
          itemCount +
              (showAppendixAsGridChild && appendixBuilder != null ? 1 : 0),
          buildSliverDelegate(
            appendixBuilder: showAppendixAsGridChild ? appendixBuilder : null,
          ),
        ),
        if (!showAppendixAsGridChild && appendixBuilder != null)
          _OffscreenMutedSliver(
            sliver: SliverToBoxAdapter(child: appendixBuilder(context)),
          ),
      ],
    );
  }
}

class _OffscreenMutedSliver extends StatelessWidget {
  const _OffscreenMutedSliver({required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    final enabled = TickerMode(enabled: true, child: sliver);
    final muted = TickerMode(enabled: false, child: sliver);
    return SliverLayoutBuilder(
      builder: (context, constraints) => constraints.remainingPaintExtent > 0 ||
              constraints.remainingCacheExtent > 0
          ? enabled
          : muted,
    );
  }
}
