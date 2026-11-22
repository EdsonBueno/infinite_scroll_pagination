import 'package:infinite_scroll_pagination/src/core/paging_state.dart';

/// All possible status for a pagination.
enum PagingStatus {
  noItemsFound,
  loadingFirstPage,
  firstPageError,
  ongoing,
  subsequentPageError,
  completed,
}

/// Extension methods for [PagingState] to determine the current status.
extension PagingStatusExtension on PagingState {
  bool get _hasItems => pages?.any((page) => page.isNotEmpty) ?? false;

  bool get _hasError => error != null;

  bool get _isLoadingFirstPage => pages == null && !_hasError && hasNextPage;

  bool get _hasFirstPageError => !_hasItems && _hasError;

  bool get _isListingUnfinished => _hasItems && hasNextPage;

  bool get _isOngoing => _isListingUnfinished && !_hasError;

  bool get _isCompleted => _hasItems && !hasNextPage;

  bool get _hasSubsequentPageError => _isListingUnfinished && _hasError;

  bool get _isEmpty => !_hasItems && (pages != null || !hasNextPage);

  /// The current pagination status.
  PagingStatus get status {
    if (_isLoadingFirstPage) return PagingStatus.loadingFirstPage;
    if (_hasFirstPageError) return PagingStatus.firstPageError;
    if (_isEmpty) return PagingStatus.noItemsFound;
    if (_isOngoing) return PagingStatus.ongoing;
    if (_hasSubsequentPageError) return PagingStatus.subsequentPageError;
    if (_isCompleted) return PagingStatus.completed;
    // This can never happen under normal circumstances.
    // coverage:ignore-start
    throw StateError('Unknown status; Did you forget to implement a case?');
    // coverage:ignore-end
  }
}
