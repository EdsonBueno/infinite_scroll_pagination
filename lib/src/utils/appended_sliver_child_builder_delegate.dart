import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A [SliverChildBuilderDelegate] with an extra item (appendixBuilder) added
/// to the end.
///
/// To include list separators, use
/// [AppendedSliverChildBuilderDelegate.separated].
class AppendedSliverChildBuilderDelegate extends SliverChildBuilderDelegate {
  AppendedSliverChildBuilderDelegate({
    required IndexedWidgetBuilder builder,
    required int childCount,
    WidgetBuilder? appendixBuilder,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    SemanticIndexCallback? semanticIndexCallback,
  }) : super(
          appendixBuilder == null
              ? builder
              : (context, index) {
                  if (index == childCount) {
                    return appendixBuilder(context);
                  }
                  return builder(context, index);
                },
          childCount: appendixBuilder == null ? childCount : childCount + 1,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback ?? (_, index) => index,
        );

  AppendedSliverChildBuilderDelegate.separated({
    required IndexedWidgetBuilder builder,
    required int childCount,
    required IndexedWidgetBuilder separatorBuilder,
    WidgetBuilder? appendixBuilder,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : this(
          builder: (context, index) {
            final itemIndex = index ~/ 2;
            if (index.isEven) {
              return builder(context, itemIndex);
            }

            return separatorBuilder(context, itemIndex);
          },
          childCount: math.max(
            0,
            childCount * 2 - (appendixBuilder != null ? 0 : 1),
          ),
          appendixBuilder: appendixBuilder,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (_, index) => index.isEven ? index ~/ 2 : null,
        );
}
