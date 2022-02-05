import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_exception_indicator.dart';

class FirstPageErrorIndicator extends StatelessWidget {
  const FirstPageErrorIndicator({
    required this.title,
    required this.message,
    required this.label,
    this.onTryAgain,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onTryAgain;
  final String title;
  final String message;
  final String label;

  @override
  Widget build(BuildContext context) => FirstPageExceptionIndicator(
        title: title, // 'Something went wrong',
        message: message, // 'The application has encountered an unknown error.\nPlease try again later.',
        label: label,
        onTryAgain: onTryAgain,
      );
}
