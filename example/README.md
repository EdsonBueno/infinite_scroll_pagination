# Cookbook

All snippets below were extracted from the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example).

## Simple Usage

```dart
class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  final CharacterListViewDataSource _dataSource = CharacterListViewDataSource();

  @override
  Widget build(BuildContext context) => 
      PagedListView<int, CharacterSummary>(
        dataSource: _dataSource,
        builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
          itemBuilder: (context, item, index) => CharacterListItem(
            character: item,
          ),
        ),
      );

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }
}

class CharacterListViewDataSource
    extends PagedDataSource<int, CharacterSummary> {
  CharacterListViewDataSource() : super(0);
  static const _pageSize = 20;

  @override
  void fetchItems(int pageKey) {
    RemoteApi.getCharacterList(pageKey, _pageSize).then((newItems) {
      final hasFinished = newItems.length < _pageSize;
      final nextPageKey =  hasFinished ? null : pageKey + newItems.length;
      notifyNewPage(newItems, nextPageKey);
    }).catchError(notifyError);
  }
}
```

## Separators
```dart
@override
Widget build(BuildContext context) => PagedListView<int, CharacterSummary>.separated(
  dataSource: _dataSource,
  builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
    itemBuilder: (context, item, index) => CharacterListItem(
        character: item,
      ),
    ),
    separatorBuilder: (context, index) => const Divider(),
  );
```

Works for both [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) and [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html).

## Preceding/Following Items
If you need to add preceding/following widgets that are expected to scroll along with your list, such as a header or a footer, you should use our [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers) widgets.
**Infinite Scroll Pagination** gives you [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html), which works almost the same as [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) or [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html), except that they need to be wrapped by a [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html). That allows you to give them siblings, for example:

```dart
@override
Widget build(BuildContext context) => 
    CustomScrollView(
      slivers: <Widget>[
        CharacterSearchInputSliver(
          onChanged: _dataSource.updateSearchTerm,
        ),
        PagedSliverList<int, CharacterSummary>(
          dataSource: _dataSource,
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
In the [preceding recipe](#precedingfollowing-items), you can see how to add a search bar widget as a list header. That example calls `updateSearchTerm` in the [PagedDataSource](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource-class.html) subclass every time the user changes the search input. That function isn't part of the package, it's just a suggestion on how to implement searching. Here you can see how that function is implemented inside the sample's [PagedDataSource](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource-class.html) subclass:

```dart
class CharacterSliverListDataSource
    extends PagedDataSource<int, CharacterSummary> {
  CharacterSliverListDataSource() : super(0);
  static const _pageSize = 17;
  // Simple mechanism to avoid having overlapping HTTP requests.
  Object _activeCallbackIdentity;

  String _searchTerm;

  @override
  void fetchItems(int pageKey) {
    final callbackIdentity = Object();

    _activeCallbackIdentity = callbackIdentity;

    RemoteApi.getCharacterList(pageKey, _pageSize, searchTerm: _searchTerm)
        .then((newItems) {
      if (callbackIdentity == _activeCallbackIdentity) {
        final hasFinished = newItems.length < _pageSize;
        notifyNewPage(newItems, hasFinished ? null : pageKey + newItems.length);
      }
    }).catchError((error) {
      if (callbackIdentity == _activeCallbackIdentity) {
        notifyError(error);
      }
    });
  }

  void updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    refresh();
  }

  @override
  void dispose() {
    _activeCallbackIdentity = null;
    super.dispose();
  }
}
```

The same structure can be applied to all kinds of filtering and sorting.

## Pull-to-Refresh
Just wrap your [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) or [CustomScrollView](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) with a [RefreshIndicator](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html) (from the [material library](https://api.flutter.dev/flutter/material/material-library.html)) and inside [onRefresh](https://api.flutter.dev/flutter/material/RefreshIndicator/onRefresh.html), call `refresh` on your [PagedDataSource](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource-class.html) instance:

```dart
@override
Widget build(BuildContext context) => 
    RefreshIndicator(
      onRefresh: () => Future.sync(
        _dataSource.refresh,
      ),
      child: PagedListView<int, CharacterSummary>(
        dataSource: _dataSource,
        builderDelegate: PagedChildBuilderDelegate<CharacterSummary>(
          itemBuilder: (context, item, index) => CharacterListItem(
            character: item,
          ),
        ),
      ),
    );
```

## Custom Layout
In case [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) doesn't work for you, you should create a new sliver layout.

Creating a new layout is just a matter of using [PagedSliverBuilder](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverBuilder-class.html) and provide it builders for the completed, in progress with error and in progress with loading layouts. For example, take a look at how [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) is built:

```dart
@override
Widget build(BuildContext context) => 
    PagedSliverBuilder<PageKeyType, ItemType>(
      dataSource: dataSource,
      builderDelegate: builderDelegate,
      invisibleItemsThreshold: invisibleItemsThreshold,
      shouldRetryOnScroll: shouldRetryOnScroll,
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
        // SliverGrid with a progress indicator as its last item.
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
        // SliverGrid with an error indicator as its last item.
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

## BLoC
**Infinite Scroll Pagination** is designed to work with any state management approach you prefer in any way you'd like. Because of that, for each approach, there's not only one, but several ways in which you could work with this package.
Below, it's just one of the possible ways to integrate it with BLoCs:

```dart
class _CharacterSliverGridState extends State<CharacterSliverGrid> {
  final CharacterSliverGridBloc _bloc = CharacterSliverGridBloc();
  CharacterSliverGridDataSource _dataSource;
  StreamSubscription _blocListingStateSubscription;

  @override
  void initState() {
    _dataSource = CharacterSliverGridDataSource(
      onPageRequested: _bloc.onPageRequestSink.add,
    );

    // We could have used StreamBuilder, but that would unnecessarily recreate
    // the entire [PagedSliverGrid] every time the state changes.
    // Instead, handling the subscription ourselves and updating only the
    // _dataSource is more efficient.
    _blocListingStateSubscription =
        _bloc.onNewListingState.listen((listingState) {
      _dataSource.notifyChange(
        listingState.itemList,
        listingState.error,
        listingState.nextKey,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: <Widget>[
          CharacterSearchInputSliver(
            onChanged: _bloc.onSearchInputChangedSink.add,
          ),
          PagedSliverGrid<int, CharacterSummary>(
            dataSource: _dataSource,
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
    _dataSource.dispose();
    _blocListingStateSubscription.cancel();
    super.dispose();
  }
}
```

```dart
class CharacterSliverGridDataSource
    extends PagedDataSource<int, CharacterSummary> {
  CharacterSliverGridDataSource({
    @required this.onPageRequested,
  }) : super(0);

  final ValueChanged<int> onPageRequested;

  @override
  void fetchItems(int pageKey) => onPageRequested(pageKey);
}
```

Check out the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example) for the complete source code.