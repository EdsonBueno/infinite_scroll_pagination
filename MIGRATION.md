# From v4 to v5

In v5, the package decouples the PagingController from PagedLayoutBuilder and its descendants, to allow greater freedom in how a PagingState is managed.
This is a large breaking change and will require refactoring in your code.

## Dependencies

The package was upgraded to a newer modern flutter major version.

- Newly requires `dart: ">=3.4.0"` and `flutter: ">=3.0.0"` for modern language features.
- Newly depends on `collection: ">=1.15.0"` for deep collection equality on `PagingState`.
- Newly depends on `meta: ">=1.8.0"` for annotations on `PagingState` extension methods.

## PagingController

Since PagingController is now optional, it was changed to be more opinionated and easier to use.

Instead of adding `PageRequestListener` to your PagingController, like so:

```dart
final pagingController = PagingController<int, Photo>(firstPageKey: 1);
pagingController.addPageRequestListener(fetchPage);
```

and manually updating the next page key:

```dart
pagingController.appendPage(newItems, nextPageKey);
```

PagingController now directly takes and controls the fetching process:

```dart
late final pagingController = PagingController<int, Photo>(
  getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
  fetchPage: (pageKey) => fetchPage(pageKey),
);
```

Fetching the next page is handled via the `fetchPage` parameter.
The result is automatically merged with the current state. To indicate whether a page is the last page, `getNextPageKey` should return `null` on its next call.
If you have complicated custom logic for computing the next page key, consider writing your own Controller or extending the PagingController.

This fixes several issues of the past:

- Requests will now be actively deduplicated
- Refresh can now cancel previous requests

The PagingController can also be arbitrarily extended to include additional functionality that you might require.
The source code explains how to structure new code.

Lastly, the various getter and setter methods previously featured to modify the state have been removed.
New getters have been added, however, setters have been left out since it should not be necessary to modify the state often.
One exception is the newly provided `mapItems` extension method, which can be used to modify the items in a convenient way, while retaining their page structure.

### API Changes

- `itemList` and `nextPageKey` properties have been removed.
- `pages`, `items`, `keys`, `error`, `hasNextPage` and `isLoading` extension getters as well as `mapItems` to modify the items have been added.
- `addPageRequestListener` was removed. Use the `fetchPage` parameter of the constructor instead.
- `appendPage` and `appendLastPage` have been removed. Use the `copyWith` method of the `PagingState` to update the `pages`, `keys` and `hasNextPage` fields.
- `retryLastFailedRequest` was removed. You can simply call `fetchNextPage` to try again.
- `invisibleItemsThreshold` parameter has been removed. To configure the `invisibleItemsThreshold` of a layout, use the corresponding parameter of its `PagedChildBuilderDelegate`.

## PagedLayoutBuilder

Because the PagingController is now independant, PagedLayoutBuilder and its subclasses no longer take a controller as a parameter like so:

```dart
PagedListView.builder(
  pagingController: pagingController,
  builderDelegate: PagedChildBuilderDelegate(
    itemBuilder: (context, item, index) => ImageListTile(item),
  ),
),
```

Instead, it is more agnostic:

```dart
PagedListView.builder(
  state: state,
  fetchNextPage: fetchNextPage,
  builderDelegate: PagedChildBuilderDelegate(
    itemBuilder: (context, item, index) => ImageListTile(item),
  ),
),
```

Taking in a `PagingState` and a `fetchNextPage` function. `fetchNextPage` is a void function, and does not receive a page key.

This new design can be used in combination with any state management solution much more easily. A PagingController is no longer required.
To continue using a PagingController for its convenience, you can connect it to any number of Paged Layouts via the PagingListener:

```dart
PagingListener(
  controller: pagingController,
  builder: (context, state, fetchNextPage) =>
    PagedListView.builder(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) => ImageListTile(item),
      ),
    ),
),
```

It is highly recommended to directly store a PagingState inside of your preferred state management solution,
instead of storing a PagingController, should you not wish to use the PagingController directly.

Examples of using a custom state management solution can be found in the example project.

### API Changes

- No longer features `pagingController` parameter. Use the `state` and `fetchNextPage` parameters instead.
- Now uses `invisibleItemsThreshold` from `PagedChildBuilderDelegate` instead of `PagingController`.

## PagingState

The PagingState has been updated to be more flexible:

- It now includes a List of all keys, `keys`, that have been fetched, each index corresponding to a page of items.
- Instead of storing the next page key, it now includes a boolean `hasNextPage` to indicate if there are more pages to fetch.
- Lastly it now also includes a loading state, in `isLoading`.

Because Items are now stored within pages, it is more difficult to modify the items directly.
To make this easier, a `mapItems` extension method has been added to modify the items by iterating over them.
Additionally, a `filterItems` extension method has been added to filter the items. This is useful for creating locally filtered computed states.

To allow for easy retrieval of the next page key, the `lastPageIsEmpty` and `nextIntPageKey` getters have been added.

The internals of PagingState have been restructured to allow directly extending it, without breaking its interface.
You can see an example of this in the PagingStateBase class.

### API Changes

- `itemList` has been replaced by `pages`, which is List<List<ItemType>> instead of List<ItemType>. An extension `items` getter is provided to flatten the list.
- `keys` is a new field that stores all keys that have been fetched, each index corresponding to a page of items.
- `error` is now type Object? instead of dynamic.
- `nextPageKey` was removed. You can use the `keys` field to compute the next page and `hasNextPage` to determine if there are more pages.
- `isLoading` is a new field that indicates if a request is currently in progress.
- `mapItems` and `filterItems` have been added to modify the items in a convenient way.
