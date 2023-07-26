import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_exception_indicator.dart';

class FirstPageErrorIndicator extends StatelessWidget {
  const FirstPageErrorIndicator({
    this.onTryAgain,
    this.tryAgainBtnTxt,
    this.title = 'Something went wrong',
    this.message = 'The application has encountered an unknown error.\n'
        'Please try again later.',
    Key? key,
  }) : super(key: key);

  final VoidCallback? onTryAgain;
  final String? tryAgainBtnTxt;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => FirstPageExceptionIndicator(
        title: title,
        message: message,
        onTryAgain: onTryAgain,
      );
}
