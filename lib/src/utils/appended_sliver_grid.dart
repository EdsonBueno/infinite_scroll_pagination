import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'appended_sliver_child_builder_delegate.dart';

typedef SliverGridBuilder = SliverWithKeepAliveWidget Function(
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
