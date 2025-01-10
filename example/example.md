# Cookbook

More extensive examples can be found in the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example).

## Using PagingController

PagingController is the out-of-the-box solution that comes with the package for managing the PagingState. Using a PagingListener, we connect it to the Paged Widget and we're good to go. You can extend the class to add features you might need, such as filtering, sorting, etc. It can also be connected to multiple Paged Widgets at the same time.

```dart
class _ExampleScreenState extends State<ExampleScreen> {
  late final _pagingController = PagingController<int, Photo>(
    getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
    fetchPage: (pageKey) => RemoteApi.getPhotos(pageKey),
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PagingListener(
    controller: _pagingController,
    builder: (context, state, fetchNextPage) => PagedListView<int, Photo>(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) => ImageListTile(item: item),
      ),
    ),
  );
}
```

## Using setState

You can manually manage the PagingState using setState. This is more straightforward when you require more control over your state.

```dart
class _ExampleScreenState extends State<ExampleScreen> {
  PagingState<int, Photo> _state = PagingState();

  void _fetchNextPage() async {
    if (_state.isLoading) return;

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? 0) + 1;
      final newItems = await RemoteApi.getPhotos(newKey);
      final isLastPage = newItems.isEmpty;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, newItems],
          keys: [...?_state.keys, newKey],
          hasNextPage: !isLastPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(
          error: error,
          isLoading: false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, Photo>(
    state: _state,
    fetchNextPage: _fetchNextPage,
    builderDelegate: PagedChildBuilderDelegate(
      itemBuilder: (context, item, index) => ImageListTile(item: item),
    ),
  );
}
```

## Using a custom State Management

You can use any state managment approach you prefer.
The only requirements for the Paged Widget to work are that you provide a PagingState and a function to fetch the next page.
Here is an example in flutter_bloc:

```dart
sealed class PhotoEvent {}

final class FetchNextPhotoPage extends PhotoEvent {}

class PhotoBoc extends Bloc<PhotoEvent, PagingState<int, Photo>> {
  PhotoBoc() : super(PagingState()) {
    on<FetchNextPhotoPage>((event, emit) {
        final state = state;
        if (state.isLoading) return;

        emit(state.copyWith(isLoading: true, error: null));

        try {
          final newKey = (state.keys?.last ?? 0) + 1;
          final newItems = await RemoteApi.getPhotos(newKey);
          final isLastPage = newItems.isEmpty;

          emit(state.copyWith(
            pages: [...?state.pages, newItems],
            keys: [...?state.keys, newKey],
            hasNextPage: !isLastPage,
            isLoading: false,
          ));
        } catch (error) {
          emit(state.copyWith(
            error: error,
            isLoading: false,
          ));
        }
      },
    );
  }
}
```

and then in your screen:

```dart
class _ExampleScreenState extends State<ExampleScreen> {
  final _bloc = PhotoBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PhotoBloc, PagingState<int, Photo>>(
    bloc: _bloc,
    builder: (context, state) => PagedListView<int, Photo>(
      state: state,
      fetchNextPage: _bloc.fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) => ImageListTile(item: item),
      ),
    ),
  );
}
```

## Customizing Indicators

You can customize the indicators by providing your own widgets to the builderDelegate. The package comes with default indicators in english.

```dart
PagedListView<int, Photo>(
  state: state,
  fetchNextPage: fetchNextPage,
  builderDelegate: PagedChildBuilderDelegate(
    itemBuilder: (context, item, index) => ImageListTile(item: item),
    firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
      error: state.error,
      onTryAgain: () => fetchNextPage(),
    ),
    newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
      error: state.error,
      onTryAgain: () => fetchNextPage(),
    ),
    firstPageProgressIndicatorBuilder: (_) => FirstPageProgressIndicator(),
    newPageProgressIndicatorBuilder: (_) => NewPageProgressIndicator(),
    noItemsFoundIndicatorBuilder: (_) => NoItemsFoundIndicator(),
    noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
  ),
);
```

## Animating Status Transitions

```dart
PagedListView<int, Photo>(
  state: state,
  fetchNextPage: fetchNextPage,
  builderDelegate: PagedChildBuilderDelegate(
    itemBuilder: (context, item, index) => ImageListTile(item: item),
    animateTransitions: true,
    // [transitionDuration] has a default value of 250 milliseconds.
    transitionDuration: const Duration(milliseconds: 500),
  ),
);
```

## Separators

```dart
PagedListView<int, Photo>.separated(
  state: state,
  fetchNextPage: fetchNextPage,
  builderDelegate: PagedChildBuilderDelegate(
    itemBuilder: (context, item, index) => ImageListTile(item: item),
  ),
  separatorBuilder: (context, index) => const Divider(),
);
```

Works for both [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) and [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html).

## Pull-to-Refresh

Wrap your [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) or [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) with a [RefreshIndicator](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html) (from the [material library](https://api.flutter.dev/flutter/material/material-library.html)) and inside [onRefresh](https://api.flutter.dev/flutter/material/RefreshIndicator/onRefresh.html), call `refresh` on your [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html):

```dart
RefreshIndicator(
  onRefresh: () => Future.sync(
    () => refresh(),
  ),
  child: PagedListView<int, Photo>(
    state: state,
    fetchNextPage: fetchNextPage,
    builderDelegate: PagedChildBuilderDelegate(
      itemBuilder: (context, item, index) => ImageListTile(item: item),
    ),
  ),
);
```

## Preceding/Following Items

If you need to place some widgets before or after your list, and expect them to scroll along with the list items, such as a header, footer, search or filter bar, you should use our [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers) widgets.

**Infinite Scroll Pagination** comes with [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html), which works almost the same as [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) or [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html), except that they need to be wrapped by a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html). That allows you to give them siblings, for example:

```dart
CustomScrollView(
  slivers: [
    SearchInputSliver(
      onChanged: updateSearchTerm,
    ),
    PagedSliverList<int, Photo>(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) => ImageListTile(item: item),
      ),
    ),
  ],
);
```

Notice that your preceding/following widgets should also be [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers)s. `SearchInputSliver`, for example, is nothing but a [TextField](https://api.flutter.dev/flutter/material/TextField-class.html) wrapped by a [SliverToBoxAdapter](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html).

## Searching/Filtering/Sorting

There are many ways to integrate searching/filtering/sorting with this package. The best one depends on you state management approach.
Below you can see a very simple example:

```dart
class _ExampleScreenState extends State<ExampleScreen> {
  String? _searchTerm;

  late final _pagingController = PagingController<int, Photo>(
    getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
    fetchPage: (pageKey) {
      final results = RemoteApi.getPhotos(pageKey);

      return _searchTerm == null
          ? results
          : results.where((photo) => photo.title.contains(_searchTerm!)).toList();
    },
  );

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomScrollView(
        slivers: [
          SearchInputSliver(
            onChanged: _updateSearchTerm,
          ),
          PagedSliverList<int, Photo>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Photo>(
              itemBuilder: (context, item, index) => ImageListTile(item: item),
            ),
          ),
        ],
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
```

The same structure can be applied to all kinds of filtering and sorting and works with any layout (not just Slivers).

## Positioning Grid's Status Indicators

By default, all our paged grid widgets show your indicators as one of the grid children, respecting the same configurations you set for your items on the `gridDelegate`.
If you want to change that, and instead display the items _below_ the grid, as is in the list widgets, you can do so by using these boolean properties:

```dart
@override
Widget build(BuildContext context) =>
    PagedGridView<int, Photo>(
      showNewPageProgressIndicatorAsGridChild: false,
      showNewPageErrorIndicatorAsGridChild: false,
      showNoMoreItemsIndicatorAsGridChild: false,
      pagingController: _pagingController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 100 / 150,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
      ),
      builderDelegate: PagedChildBuilderDelegate<Photo>(
        itemBuilder: (context, item, index) => ImageListTile(item: item),
      ),
    );
```

## Changing the Invisible Items Threshold

By default, the package asks a new page when there are 3 invisible items left while the user is scrolling. You can change that number in the [PagedChildBuilderDelegate](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedChildBuilderDelegate-class.html).

```dart
PagedListView<int, Photo>(
  state: state,
  fetchNextPage: fetchNextPage,
  builderDelegate: PagedChildBuilderDelegate(
    itemBuilder: (context, item, index) => ImageListTile(item: item),
    invisibleItemsThreshold: 5,
  ),
);
```

## Custom Layout

In case [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) doesn't work for you, you should create a new paged layout.

Creating a new layout is just a matter of using [PagedLayoutBuilder](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedLayoutBuilder-class.html) and provide it builders for the completed, in progress with error and in progress with loading layouts. For example, take a look at how [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) is built:

```dart
PagedLayoutBuilder<PageKeyType, ItemType>(
  layoutProtocol: PagedLayoutProtocol.sliver,
  pagingController: pagingController,
  builderDelegate: builderDelegate,
  completedListingBuilder: (
    context,
    itemBuilder,
    itemCount,
    noMoreItemsIndicatorBuilder,
  ) =>
      AppendedSliverGrid(
    sliverGridBuilder: (_, delegate) => SliverGrid(
      delegate: delegate,
      gridDelegate: gridDelegate,
    ),
    itemBuilder: itemBuilder,
    itemCount: itemCount,
    appendixBuilder: noMoreItemsIndicatorBuilder,
    showAppendixAsGridChild: showNoMoreItemsIndicatorAsGridChild,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addSemanticIndexes: addSemanticIndexes,
    addRepaintBoundaries: addRepaintBoundaries,
  ),
  loadingListingBuilder: (
    context,
    itemBuilder,
    itemCount,
    progressIndicatorBuilder,
  ) =>
      AppendedSliverGrid(
    sliverGridBuilder: (_, delegate) => SliverGrid(
      delegate: delegate,
      gridDelegate: gridDelegate,
    ),
    itemBuilder: itemBuilder,
    itemCount: itemCount,
    appendixBuilder: progressIndicatorBuilder,
    showAppendixAsGridChild: showNewPageProgressIndicatorAsGridChild,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addSemanticIndexes: addSemanticIndexes,
    addRepaintBoundaries: addRepaintBoundaries,
  ),
  errorListingBuilder: (
    context,
    itemBuilder,
    itemCount,
    errorIndicatorBuilder,
  ) =>
      AppendedSliverGrid(
    sliverGridBuilder: (_, delegate) => SliverGrid(
      delegate: delegate,
      gridDelegate: gridDelegate,
    ),
    itemBuilder: itemBuilder,
    itemCount: itemCount,
    appendixBuilder: errorIndicatorBuilder,
    showAppendixAsGridChild: showNewPageErrorIndicatorAsGridChild,
    addAutomaticKeepAlives: addAutomaticKeepAlives,
    addSemanticIndexes: addSemanticIndexes,
    addRepaintBoundaries: addRepaintBoundaries,
  ),
  shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
);
```

Note the usage of [PagedLayoutProtocol.sliver](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedLayoutProtocol/sliver.html) which tells the package that the layout is a [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers).
For widgets which have no Sliver variant, such as a [PagedPageView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedPageView-class.html), you should use [PagedLayoutProtocol.box](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedLayoutProtocol/box.html) instead.
