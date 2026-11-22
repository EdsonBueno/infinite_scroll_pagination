import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    SemanticIndexCallback? semanticIndexCallback,
    super.findChildIndexCallback,
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
    ChildIndexGetter? findChildIndexCallback,
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
         findChildIndexCallback: findChildIndexCallback == null
             ? null
             : (key) => switch (findChildIndexCallback(key)) {
                 final itemIndex? => itemIndex * 2,
                 null => null,
               },
       );
}
