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

    return SliverMainAxisGroup(
      slivers: [
        sliverGridBuilder(
          itemCount +
              (showAppendixAsGridChild && appendixBuilder != null ? 1 : 0),
          _buildSliverDelegate(
            appendixBuilder: showAppendixAsGridChild ? appendixBuilder : null,
          ),
        ),
        if (!showAppendixAsGridChild)
          SliverToBoxAdapter(
            child: appendixBuilder?.call(context),
          ),
      ],
    );
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
