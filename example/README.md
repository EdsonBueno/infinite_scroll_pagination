# Cookbook

All the snippets are from the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example).

## Simple Usage

```dart
class BeerListView extends StatefulWidget {
  @override
  _BeerListViewState createState() => _BeerListViewState();
}

class _BeerListViewState extends State<BeerListView> {
  static const _pageSize = 20;

  final PagingController<int, BeerSummary> _pagingController =
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
      final newItems = await RemoteApi.getBeerList(pageKey, _pageSize);
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
      PagedListView<int, BeerSummary>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
          itemBuilder: (context, item, index) => BeerListItem(
            beer: item,
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
    PagedListView<int, BeerSummary>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
        itemBuilder: (context, item, index) => BeerListItem(
          beer: item,
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
    PagedListView<int, BeerSummary>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
        animateTransitions: true,
        // [transitionDuration] has a default value of 250 milliseconds.
        transitionDuration: const Duration(milliseconds: 500),
        itemBuilder: (context, item, index) => BeerListItem(
          beer: item,
        ),
      ),
    );
```

## Separators

```dart
@override
Widget build(BuildContext context) =>
    PagedListView<int, BeerSummary>.separated(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
        itemBuilder: (context, item, index) => BeerListItem(
          beer: item,
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
      child: PagedListView<int, BeerSummary>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
          itemBuilder: (context, item, index) => BeerListItem(
            beer: item,
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
        BeerSearchInputSliver(
          onChanged: _updateSearchTerm,
        ),
        PagedSliverList<int, BeerSummary>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
            itemBuilder: (context, item, index) => BeerListItem(
              beer: item,
            ),
          ),
        ),
      ],
    );
```

Notice that your preceding/following widgets should also be [Sliver](https://flutter.dev/docs/development/ui/advanced/slivers)s. `BeerSearchInputSliver`, for example, is nothing but a [TextField](https://api.flutter.dev/flutter/material/TextField-class.html) wrapped by a [SliverToBoxAdapter](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html).

## Searching/Filtering/Sorting

There are many ways to integrate searching/filtering/sorting with this package. The best one depends on you state management approach. Below you can see a simple example for a vanilla approach:

```dart
class BeerSliverList extends StatefulWidget {
  @override
  _BeerSliverListState createState() => _BeerSliverListState();
}

class _BeerSliverListState extends State<BeerSliverList> {
  static const _pageSize = 17;

  final PagingController<int, BeerSummary> _pagingController =
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
      final newItems = await RemoteApi.getBeerList(
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
          BeerSearchInputSliver(
            onChanged: _updateSearchTerm,
          ),
          PagedSliverList<int, BeerSummary>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
              itemBuilder: (context, item, index) => BeerListItem(
                beer: item,
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

By default, all our paged grid widgets show your indicators as one of the grid children, respecting the same configurations you set for your items on the `gridDelegate`.
If you want to change that, and instead display the items _below_ the grid, as is in the list widgets, you can do so by using these boolean properties:

```dart
@override
Widget build(BuildContext context) =>
    PagedGridView<int, BeerSummary>(
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
      builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
        itemBuilder: (context, item, index) => BeerGridItem(
          beer: item,
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
final PagingController<int, BeerSummary> _pagingController =
      PagingController(firstPageKey: 0, invisibleItemsThreshold: 5);
```

## BLoC

**Infinite Scroll Pagination** is designed to work with any state management approach you prefer in any way you'd like. Because of that, for each approach, there's not only one, but several ways in which you could work with this package.
Below you can see one of the possible ways to integrate it with BLoCs:

```dart
class BeerSliverGrid extends StatefulWidget {
  @override
  _BeerSliverGridState createState() => _BeerSliverGridState();
}

class _BeerSliverGridState extends State<BeerSliverGrid> {
  final BeerSliverGridBloc _bloc = BeerSliverGridBloc();
  final PagingController<int, BeerSummary> _pagingController =
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
          BeerSearchInputSliver(
            onChanged: (searchTerm) =>
                _bloc.onSearchInputChangedSink.add(searchTerm),
          ),
          PagedSliverGrid<int, BeerSummary>(
            pagingController: _pagingController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 100 / 150,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
            ),
            builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
              itemBuilder: (context, item, index) => BeerGridItem(
                beer: item,
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

In case [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html), [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html), [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html) and [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) doesn't work for you, you should create a new paged layout.

Creating a new layout is just a matter of using [PagedLayoutBuilder](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedLayoutBuilder-class.html) and provide it builders for the completed, in progress with error and in progress with loading layouts. For example, take a look at how [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) is built:

```dart
@override
  @override
  Widget build(BuildContext context) =>
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
