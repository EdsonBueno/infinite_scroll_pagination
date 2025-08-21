import 'package:infinite_scroll_pagination/src/core/extensions.dart';
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
  /// The current pagination status.
  PagingStatus get status {
    final hasPages = pages.isNotEmpty;
    final hasError = error != null;
    final hasItems = items?.isNotEmpty ?? false;

    if (hasError) {
      if (!hasPages) return PagingStatus.firstPageError;
      if (hasNextPage) return PagingStatus.subsequentPageError;
      return PagingStatus.completed;
    }

    if (!hasItems && !hasNextPage) return PagingStatus.noItemsFound;

    if (!hasPages) return PagingStatus.loadingFirstPage;
    if (hasNextPage) return PagingStatus.ongoing;

    return PagingStatus.completed;
  }
}
