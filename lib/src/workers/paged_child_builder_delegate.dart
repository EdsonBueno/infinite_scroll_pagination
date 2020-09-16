import 'package:flutter/widgets.dart';

typedef ItemWidgetBuilder<ItemType> = Function(
  BuildContext context,
  ItemType item,
  int index,
);

typedef ErrorIndicatorWidgetBuilder = Function(
  BuildContext context,
  dynamic error,
  VoidCallback retry,
);

/// Supplies builders for the visual components of paged views.
///
/// The generic type [ItemType] must be specified in order to properly identify
/// the list item’s type.
class PagedChildBuilderDelegate<ItemType> {
  PagedChildBuilderDelegate({
    @required this.itemBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
  }) : assert(itemBuilder != null);

  /// The builder for list items.
  final ItemWidgetBuilder<ItemType> itemBuilder;

  /// The builder for the first page's error indicator.
  final ErrorIndicatorWidgetBuilder firstPageErrorIndicatorBuilder;

  /// The builder for a new page's error indicator.
  final ErrorIndicatorWidgetBuilder newPageErrorIndicatorBuilder;

  /// The builder for the first page's progress indicator.
  final WidgetBuilder firstPageProgressIndicatorBuilder;

  /// The builder for a new page's progress indicator.
  final WidgetBuilder newPageProgressIndicatorBuilder;

  /// The builder for a no items list indicator.
  final WidgetBuilder noItemsFoundIndicatorBuilder;
}
