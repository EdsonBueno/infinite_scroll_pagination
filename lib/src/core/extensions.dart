import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/core/paging_status.dart';
import 'package:meta/meta.dart';

/// Helper extensions to make working with [PagingState] easier.
extension PagingStateExtension<PageKeyType, ItemType>
    on PagingState<PageKeyType, ItemType> {
  /// The list of items fetched so far. A flattened version of [pages].
  List<ItemType>? get items =>
      pages != null ? List.unmodifiable(pages!.expand((e) => e)) : null;

  /// Convenience method to update the items of the state by applying a mapper function to each item.
  ///
  /// The result of this method is a new [PagingState] with the same properties as the original state
  /// except for the items, which are replaced by the mapped items.
  @UseResult('Use the returned value as new state.')
  PagingState<PageKeyType, ItemType> mapItems(
    ItemType Function(ItemType item) mapper,
  ) =>
      copyWith(
        pages: pages?.map((page) => page.map(mapper).toList()).toList(),
      );

  /// Convenience method to filter the items of the state by applying a predicate function to each item.
  ///
  /// The result of this method is a new [PagingState] with the same properties as the original state
  /// except for the items, which are replaced by the filtered items.
  ///
  /// It is not recommended to reassign the result of this method back to a state variable, because
  /// the filtered items will be lost. Instead, use the returned value as computed state only.
  /// This extension is absent from the [PagingController] extension for this reason.
  @UseResult('Use the returned value as computed state.')
  PagingState<PageKeyType, ItemType> filterItems(
    bool Function(ItemType item) predicate,
  ) =>
      copyWith(
        pages: pages?.map((page) => page.where(predicate).toList()).toList(),
      );

  /// Convenience getter to check if the last page is empty.
  /// This is useful if your API returns an empty page when there are no more items to fetch.
  ///
  /// Checking for the last page in this manner is more robust than checking if the returned page
  /// has less than the expected number of items, because it does not require knowing the page size.
  /// However, it can be potentially wasteful, since one additional empty page will be fetched.
  bool get lastPageIsEmpty => pages?.lastOrNull?.isEmpty ?? false;
}

/// Helper extensions to make working with [PagingState] with integer keys easier.
extension IntPagingStateExtension<ItemType> on PagingState<int, ItemType> {
  /// Convenience method to get the next page key.
  ///
  /// Assumes that keys start at 1 and increment by 1.
  int get nextIntPageKey => (keys?.lastOrNull ?? 0) + 1;
}

/// Helper extensions to quickly access the state of a [PagingController].
extension PagingControllerExtension<PageKeyType, ItemType>
    on PagingController<PageKeyType, ItemType> {
  /// The pages fetched so far.
  List<List<ItemType>>? get pages => value.pages;

  /// The items fetched so far. A flattened version of [pages].
  List<ItemType>? get items => value.items;

  /// Convenience method to update the items of the state.
  ///
  /// Items cannot be directly assigned, because they are backed by a list of pages.
  void mapItems(ItemType Function(ItemType item) mapper) =>
      value = value.mapItems(mapper);

  /// The keys of the pages fetched so far.
  List<PageKeyType>? get keys => value.keys;

  /// The last error that occurred while fetching a page.
  Object? get error => value.error;

  /// Will be `true` if there is a next page to be fetched.
  bool get hasNextPage => value.hasNextPage;

  /// Will be `true` if a page is currently being fetched.
  bool get isLoading => value.isLoading;

  /// The paging status.
  PagingStatus get status => value.status;
}
