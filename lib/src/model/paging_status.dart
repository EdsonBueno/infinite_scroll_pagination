import 'package:infinite_scroll_pagination/src/model/paging_state.dart';

/// All possible status for a pagination.
enum PagingStatus {
  completed,
  noItemsFound,
  loadingFirstPage,
  ongoing,
  firstPageError,
  subsequentPageError,
}

/// Extension methods for [PagingState] to determine the current status.
extension PagingStatusExtension on PagingState {
  int? get _itemCount => items?.length;

  bool get _hasItems {
    final itemCount = _itemCount;
    return itemCount != null && itemCount > 0;
  }

  bool get _hasError => error != null;

  bool get _isLoadingFirstPage => _itemCount == null && !_hasError;

  bool get _hasFirstPageError => !_hasItems && _hasError;

  bool get _isListingUnfinished => _hasItems && hasNextPage;

  bool get _isOngoing => _isListingUnfinished && !_hasError;

  bool get _isCompleted => _hasItems && !hasNextPage;

  bool get _hasSubsequentPageError => _isListingUnfinished && _hasError;

  bool get _isEmpty => _itemCount != null && _itemCount == 0;

  /// The current pagination status.
  PagingStatus get status {
    if (_isLoadingFirstPage) return PagingStatus.loadingFirstPage;
    if (_hasFirstPageError) return PagingStatus.firstPageError;
    if (_isEmpty) return PagingStatus.noItemsFound;
    if (_isOngoing) return PagingStatus.ongoing;
    if (_hasSubsequentPageError) return PagingStatus.subsequentPageError;
    if (_isCompleted) return PagingStatus.completed;
    throw StateError('Unknown status; Did you forget to implement a case?');
  }
}
