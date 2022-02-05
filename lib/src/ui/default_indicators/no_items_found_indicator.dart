import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_exception_indicator.dart';

class NoItemsFoundIndicator extends StatelessWidget {

  NoItemsFoundIndicator({
    required this.title,
    required this.message,
    required this.label
  });
  final String title;
  final String message;
  final String label;

  @override
  Widget build(BuildContext context) => FirstPageExceptionIndicator(
        title: title, //'No items found',
        message: message,//'The list is currently empty.',
        label: label,
      );
}
