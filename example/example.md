# Cookbook

All the snippets are from the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example).

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

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await RemoteApi.getCharacterList(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => 
      PagedListView<int, CharacterSummary>(
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
Widget build(BuildContext context) => 
    PagedListView<int, CharacterSummary>(
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
          onTryAgain: () => _pagingController.retryLastFailedRequest(),
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
@override
Widget build(BuildContext context) =>
    PagedListView<int, CharacterSummary>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
        animateTransitions: true,
        // [transitionDuration] has a default value of 250 milliseconds.
        transitionDuration: const Duration(milliseconds: 500),
        itemBuilder: (context, item, index) => CharacterListItem(
          character: item,
        ),
      ),
    );
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
Wrap your [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) or [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) with a [RefreshIndicator](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html) (from the [material library](https://api.flutter.dev/flutter/material/material-library.html)) and inside [onRefresh](https://api.flutter.dev/flutter/material/RefreshIndicator/onRefresh.html), call `refresh` on your [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html):

```dart
@override
Widget build(BuildContext context) => 
    RefreshIndicator(
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
If you need to place some widgets before or after your list, and expect them to scroll along with the list items, such as a header, footer, search or filter bar, you should use our [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers) widgets.

**Infinite Scroll Pagination** comes with [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html), which works almost the same as [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) or [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html), except that they need to be wrapped by a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html). That allows you to give them siblings, for example:

```dart
@override
Widget build(BuildContext context) => 
    CustomScrollView(
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
```

Notice that your preceding/following widgets should also be [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers)s. `CharacterSearchInputSliver`, for example, is nothing but a [TextField](https://api.flutter.dev/flutter/material/TextField-class.html) wrapped by a [SliverToBoxAdapter](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html).

## Searching/Filtering/Sorting

There are many ways to integrate searching/filtering/sorting with this package. The best one depends on you state management approach. Below you can see a simple example for a vanilla approach:

```dart
class CharacterSliverList extends StatefulWidget {
  @override
  _CharacterSliverListState createState() => _CharacterSliverListState();
}

class _CharacterSliverListState extends State<CharacterSliverList> {
  static const _pageSize = 17;

  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0);

  String? _searchTerm;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    super.initState();
  }

  Future<void> _fetchPage(pageKey) async {
    try {
      final newItems = await RemoteApi.getCharacterList(
        pageKey,
        _pageSize,
        searchTerm: _searchTerm,
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => 
      CustomScrollView(
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

## Positioning Grid's Status Indicators
By default, both [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) show your indicators as one of the grid children, respecting the same configurations you set for your items on the `gridDelegate`.
If you want to change that, and instead display the items *below* the grid, as is in the list widgets, you can do so by using these boolean properties:

```dart
@override
Widget build(BuildContext context) => 
    PagedGridView<int, CharacterSummary>(
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
      builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
        itemBuilder: (context, item, index) => CharacterGridItem(
          character: item,
        ),
      ),
    );
```

## Listening to Status Changes

If you need to execute some custom action when the list status changes, such as displaying a dialog/snackbar/toast, or sending a custom event to a BLoC or so, add a status listener to your [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html). For example:

```dart
@override
void initState() {
  _pagingController.addPageRequestListener((pageKey) {
    _fetchPage(pageKey);
  });

  _pagingController.addStatusListener((status) {
    if (status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.retryLastFailedRequest(),
          ),
        ),
      );
    }
  });

  super.initState();
}
```

## Changing the Invisible Items Threshold
By default, the package asks a new page when there are 3 invisible items left while the user is scrolling. You can change that number in the [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html)'s constructor.

```dart
final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0, invisibleItemsThreshold: 5);
```

## BLoC
**Infinite Scroll Pagination** is designed to work with any state management approach you prefer in any way you'd like. Because of that, for each approach, there's not only one, but several ways in which you could work with this package.
Below you can see one of the possible ways to integrate it with BLoCs:

```dart
class CharacterSliverGrid extends StatefulWidget {
  @override
  _CharacterSliverGridState createState() => _CharacterSliverGridState();
}

class _CharacterSliverGridState extends State<CharacterSliverGrid> {
  final CharacterSliverGridBloc _bloc = CharacterSliverGridBloc();
  final PagingController<int, CharacterSummary> _pagingController =
      PagingController(firstPageKey: 0);
  late StreamSubscription _blocListingStateSubscription;

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
  Widget build(BuildContext context) => 
      CustomScrollView(
        slivers: <Widget>[
          CharacterSearchInputSliver(
            onChanged: (searchTerm) =>
                _bloc.onSearchInputChangedSink.add(searchTerm),
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
        noMoreItemsIndicatorBuilder,
      ) =>
          SliverGrid(
        gridDelegate: gridDelegate,
        delegate: _buildSliverDelegate(
          itemBuilder,
          itemCount,
          statusIndicatorBuilder: noMoreItemsIndicatorBuilder,
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

Notice that your resulting widget will be a [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers), and as such, you need to wrap it with a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) before adding it to the screen.
