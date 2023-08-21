import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/first_page_exception_indicator.dart';

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({
    Key? key,
    this.title = 'No items found',
    this.message = 'The list is currently empty.',
  }) : super(key: key);

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => FirstPageExceptionIndicator(
        title: title,
        message: message,
      );
}
