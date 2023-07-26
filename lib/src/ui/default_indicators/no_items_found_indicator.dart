import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_exception_indicator.dart';

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({
    Key? key,
    this.title = 'No items found',
    this.message = 'The list is currently empty.',
    this.child,
  }) : super(key: key);

  final String title;
  final String message;
  final Widget? child;
  @override
  Widget build(BuildContext context) =>
      child ??
      FirstPageExceptionIndicator(
        title: title,
        message: message,
      );
}
