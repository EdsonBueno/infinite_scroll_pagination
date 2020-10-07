# Cookbook

All the snippets below were extracted from the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example).

## Simple Usage

```dart
class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  static const _pageSize = 20;

  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) {
    RemoteApi.getCharacterList(pageKey, _pageSize).then((newItems) {
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    }).catchError((error) {
      _pagingController.error = error;
    });
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, CharacterSummary>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
          itemBuilder: (context, item, index) => CharacterListItem(
            character: item,
          ),
        ),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
```

## Customizing Indicators

```dart
@override
  Widget build(BuildContext context) => PagedListView<int, CharacterSummary>(
    pagingController: _pagingController,
    builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
      itemBuilder: (context, item, index) => CharacterListItem(
        character: item,
      ),
      firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
        error: _pagingController.error,
        onTryAgain: () => _pagingController.refresh(),
      ),
      newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
        error: _pagingController.error,
        onTryAgain: () => _pagingController.retryLastRequest(),
      ),
      firstPageProgressIndicatorBuilder: (_) => FirstPageProgressIndicator(),
      newPageProgressIndicatorBuilder: (_) => NewPageProgressIndicator(),
      noItemsFoundIndicatorBuilder: (_) => NoItemsFoundIndicator(),
    ),
  );
```

## Changing the Invisible Items Threshold
By default, the package asks a new page when there are 3 invisible items left while the user is scrolling. You can change that number in the [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html)'s constructor.

```dart
final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0, invisibleItemsThreshold: 5);
```

## Separators
```dart
@override
Widget build(BuildContext context) =>
    PagedListView<int, CharacterSummary>.separated(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
        itemBuilder: (context, item, index) => CharacterListItem(
          character: item,
        ),
      ),
      separatorBuilder: (context, index) => const Divider(),
    );
```

Works for both [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) and [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html).

## Pull-to-Refresh
Simply wrap your [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) or [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) with a [RefreshIndicator](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html) (from the [material library](https://api.flutter.dev/flutter/material/material-library.html)) and inside [onRefresh](https://api.flutter.dev/flutter/material/RefreshIndicator/onRefresh.html), call `refresh` on your [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html) instance:

```dart
@override
Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: PagedListView<int, CharacterSummary>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
          itemBuilder: (context, item, index) => CharacterListItem(
            character: item,
          ),
        ),
      ),
    );
```

## Preceding/Following Items
If you need to add preceding or following widgets that are expected to scroll along with your list, such as a header or a footer, you should use our [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers) widgets.
**Infinite Scroll Pagination** comes with [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html), which works almost the same as [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) or [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html), except that they need to be wrapped by a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html). That allows you to give them siblings, for example:

```dart
@override
Widget build(BuildContext context) => CustomScrollView(
      slivers: <Widget>[
       CharacterSearchInputSliver(
          onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
        ),
        PagedSliverList<int, CharacterSummary>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
            itemBuilder: (context, item, index) => CharacterListItem(
              character: item,
            ),
          ),
        ),
      ],
    );
```

Notice that your preceding/following widgets should also be [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers)s. `CharacterSearchInputSliver`, for example, is nothing but a [TextField](https://api.flutter.dev/flutter/material/TextField-class.html) wrapped by a [SliverToBoxAdapter](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html).

If you're adding a single widget, as in the example, [SliverToBoxAdapter](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html) will do the job. If you need to add a *list* of preceding/following items, you can use a [SliverList](https://api.flutter.dev/flutter/widgets/SliverList-class.html).

## Searching/Filtering/Sorting
In the [preceding recipe](https://pub.dev/packages/infinite_scroll_pagination/example#precedingfollowing-items), you can see how to add a search bar widget as a list header. That example calls a function named `_updateSearchTerm` every time the user changes the search input. That function isn't part of the package, it's just a suggestion on how to implement searching. Here's the complete code:

```dart
class CharacterSliverList extends StatefulWidget {
  @override
  _CharacterSliverListState createState() => _CharacterSliverListState();
}

class _CharacterSliverListState extends State<CharacterSliverList> {
  static const _pageSize = 17;

  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0);

  String _searchTerm;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    
    super.initState();
  }

  void _fetchPage(pageKey) {
    RemoteApi.getCharacterList(pageKey, _pageSize, searchTerm: _searchTerm)
        .then((newItems) {
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    }).catchError((error) {
      _pagingController.error = error;
    });
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: <Widget>[
          CharacterSearchInputSliver(
            onChanged: _updateSearchTerm,
          ),
          PagedSliverList<int, CharacterSummary>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
              itemBuilder: (context, item, index) => CharacterListItem(
                character: item,
              ),
            ),
          ),
        ],
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
}
```

The same structure can be applied to all kinds of filtering and sorting and works with any layout (not just Slivers).

## Listening to Status Changes

If you need to execute some action when the list status changes, such as displaying a dialog/snackbar/toast, or sending a custom event to a BLoC or so, add a status listener to your [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html). For example:

```dart
@override
void initState() {
  _pagingController.addPageRequestListener((pageKey) {
    _fetchPage(pageKey);
  });

  _pagingController.addStatusListener((status) {
    if (status == PagingStatus.subsequentPageError) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.retryLastRequest(),
          ),
        ),
      );
    }
  });

  super.initState();
}
```

## BLoC
**Infinite Scroll Pagination** is designed to work with any state management approach you prefer in any way you'd like. Because of that, for each approach, there's not only one, but several ways in which you could work with this package.
Below, it's just one of the possible ways to integrate it with BLoCs:

```dart
class _CharacterSliverGridState extends State<CharacterSliverGrid> {
  final CharacterSliverGridBloc _bloc = CharacterSliverGridBloc();
  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0);
  StreamSubscription _blocListingStateSubscription;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _bloc.onPageRequestSink.add(pageKey);
    });

    // We could've used StreamBuilder, but that would unnecessarily recreate
    // the entire [PagedSliverGrid] every time the state changes.
    // Instead, handling the subscription ourselves and updating only the
    // _pagingController is more efficient.
    _blocListingStateSubscription =
        _bloc.onNewListingState.listen((listingState) {
      _pagingController.value = PagingState(
        nextPageKey: listingState.nextPageKey,
        error: listingState.error,
        itemList: listingState.itemList,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: <Widget>[
          CharacterSearchInputSliver(
            onChanged: (searchTerm) => _bloc.onSearchInputChangedSink.add(searchTerm),
          ),
          PagedSliverGrid<int, CharacterSummary>(
            pagingController: _pagingController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 100 / 150,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
            ),
            builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
              itemBuilder: (context, item, index) => CharacterGridItem(
                character: item,
              ),
            ),
          ),
        ],
      );

  @override
  void dispose() {
    _pagingController.dispose();
    _blocListingStateSubscription.cancel();
    super.dispose();
  }
}
```

Check out the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example) for the complete source code.

## Custom Layout
In case [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) doesn't work for you, you should create a new sliver layout.

Creating a new layout is just a matter of using [PagedSliverBuilder](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverBuilder-class.html) and provide it builders for the completed, in progress with error and in progress with loading layouts. For example, take a look at how [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) is built:

```dart
@override
Widget build(BuildContext context) =>
    PagedSliverBuilder<PageKeyType, ItemType>(
      pagingController: pagingController,
      builderDelegate: builderDelegate,
      completedListingBuilder: (
        context,
        itemBuilder,
        itemCount,
      ) =>
          SliverGrid(
        gridDelegate: gridDelegate,
        delegate: _buildSliverDelegate(
          itemBuilder,
          itemCount,
        ),
      ),
      loadingListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        progressIndicatorBuilder,
      ) =>
          SliverGrid(
        gridDelegate: gridDelegate,
        delegate: _buildSliverDelegate(
          itemBuilder,
          itemCount,
          statusIndicatorBuilder: progressIndicatorBuilder,
        ),
      ),
      errorListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        errorIndicatorBuilder,
      ) =>
          SliverGrid(
        gridDelegate: gridDelegate,
        delegate: _buildSliverDelegate(
          itemBuilder,
          itemCount,
          statusIndicatorBuilder: errorIndicatorBuilder,
        ),
      ),
    );
```

Notice that your resulting widget will be a [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers), and as such, you need to wrap it with a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) before adding to the screen.
