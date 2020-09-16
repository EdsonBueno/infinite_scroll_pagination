import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/utils/listenable_listener.dart';

/// Listens to state changes on a given [PagedDataSource].
class PagedStateChangeListener extends StatelessWidget {
  const PagedStateChangeListener({
    @required this.dataSource,
    @required this.child,
    this.onListingWithLoading,
    this.onLoadingFirstPage,
    this.onListingCompleted,
    this.onListingWithError,
    this.onNoItemsFound,
    this.onFirstPageError,
    Key key,
  })  : assert(dataSource != null),
        assert(child != null),
        super(key: key);

  /// The data source to be listened.
  final PagedDataSource dataSource;

  /// Called when the listing is with a progress indicator at the bottom.
  final VoidCallback onListingWithLoading;

  /// Called when the [dataSource] is loading the first page.
  final VoidCallback onLoadingFirstPage;

  /// Called when the listing has fetched all items.
  final VoidCallback onListingCompleted;

  /// Called when the [dataSource] fails fetching a subsequent page.
  final VoidCallback onListingWithError;

  /// Called when the listing has no items and no errors.
  final VoidCallback onNoItemsFound;

  /// Called when an error occurred fetching the first page.
  final VoidCallback onFirstPageError;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) => ListenableListener(
        listenable: dataSource,
        listener: _callListenerByStatus,
        child: child,
      );

  void _callListenerByStatus() {
    if (dataSource.isListingWithLoading) {
      onListingWithLoading?.call();
      return;
    }

    if (dataSource.isListingCompleted) {
      onListingCompleted?.call();
      return;
    }

    if (dataSource.isLoadingFirstPage) {
      onLoadingFirstPage?.call();
      return;
    }

    if (dataSource.isListingWithError) {
      onListingWithError?.call();
      return;
    }

    if (dataSource.isListEmpty) {
      onNoItemsFound?.call();
    } else {
      onFirstPageError?.call();
    }
  }
}
