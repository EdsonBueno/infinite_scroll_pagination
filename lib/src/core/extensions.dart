import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:infinite_scroll_pagination/src/core/paging_state.dart';
import 'package:infinite_scroll_pagination/src/core/paging_status.dart';
import 'package:meta/meta.dart';

extension PagingStateExtension<PageKeyType extends Object,
    ItemType extends Object> on PagingState<PageKeyType, ItemType> {
  /// The list of items fetched so far. A flattened version of [pages].
  List<ItemType>? get items =>
      pages != null ? List.unmodifiable(pages!.expand((e) => e)) : null;

  /// Convenience method to update the items of the state by applying a mapper function to each item.
  ///
  /// The result of this method is a new [PagingState] with the same properties as the original state
  /// except for the items, which are replaced by the mapped items.
  @UseResult('Use the returned value as your new state.')
  PagingState<PageKeyType, ItemType> mapItems(
    ItemType Function(ItemType item) mapper,
  ) =>
      copyWith(
        pages: pages?.map((page) => page.map(mapper).toList()).toList(),
      );
}

/// Helper extensions to quickly access the state of a [PagingController].
extension PagingControllerExtension<PageKeyType extends Object,
    ItemType extends Object> on PagingController<PageKeyType, ItemType> {
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
