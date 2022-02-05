


class InternationalizationHelper {
  final String firstPageErrorIndicatorTitle;
  final String firstPageErrorIndicatorMessage;
  final String tryAgainText;
  final String newPageErrorIndicatorMessage;
  final String noItemsFoundIndicatorTitle;
  final String noItemsFoundIndicatorMessage;


  InternationalizationHelper({
    this.firstPageErrorIndicatorTitle = 'Something went wrong',
    this.firstPageErrorIndicatorMessage = 'The application has encountered '
        'an unknown error.\n'
        'Please try again later.',
    this.tryAgainText = 'Try Again',
    this.newPageErrorIndicatorMessage =
      'Something went wrong. Tap to try again.',
    this.noItemsFoundIndicatorTitle = 'No items found',
    this.noItemsFoundIndicatorMessage = 'The list is currently empty.',
  });
}