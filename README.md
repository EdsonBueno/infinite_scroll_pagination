<p align="center">
	<img src="https://raw.githubusercontent.com/EdsonBueno/infinite_scroll_pagination/master/docs/assets/logo.png" style="max-height: 130px;" alt="Infinite Scroll Pagination Logo" />
</p>
<p align="center">
	<a href="https://pub.dev/packages/infinite_scroll_pagination"><img src="https://img.shields.io/pub/v/infinite_scroll_pagination.svg" alt="Pub.dev Badge"></a>
	<a href="https://github.com/EdsonBueno/infinite_scroll_pagination/actions"><img src="https://github.com/EdsonBueno/infinite_scroll_pagination/workflows/build/badge.svg" alt="GitHub Build Badge"></a>
	<a href="https://gitter.im/infinite_scroll_pagination/community"><img src="https://badges.gitter.im/infinite_scroll_pagination/community.svg" alt="Gitter Badge"></a>
	<a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="Effective Dart Badge"></a>
	<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="MIT License Badge"></a>
	<a href="https://github.com/EdsonBueno/infinite_scroll_pagination"><img src="https://img.shields.io/badge/platform-flutter-ff69b4.svg" alt="Flutter Platform Badge"></a>
</p>

---

# Infinite Scroll Pagination

Unopinionated, extensible and highly customizable package to help you lazily load and display small chunks of data as the user scrolls down your screen – known as infinite scrolling pagination, endless scrolling pagination, auto-pagination, lazy loading pagination, progressive loading pagination, etc.

Inspired by the ergonomics of the Flutter API itself.

<img src="https://raw.githubusercontent.com/EdsonBueno/infinite_scroll_pagination/master/docs/assets/demo.gif" alt="Example Project" />

## Usage

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
      final nextPageKey =  hasFinished ? null : (pageKey + newItems.length);
      notifyNewPage(newItems, nextPageKey);
    }).catchError(notifyError);
  }
}
```

For more usage examples, please take a look at our [cookbook](https://pub.dev/packages/infinite_scroll_pagination/example) or check out the [example project](https://github.com/EdsonBueno/infinite_scroll_pagination/tree/master/example).

## Features

- **Architecture-agnostic**: Works with any state management approach, from [setState](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#setstate) to [BLoC](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx). Not even [Future](https://api.flutter.dev/flutter/dart-async/Future-class.html) usage is assumed.

- **Layout-agnostic**: Out-of-the-box widgets equivalent to [GridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html), [SliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html), [ListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) and [SliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html) – including `.separated` constructors. Not enough? You can [easily create a custom layout](https://pub.dev/packages/infinite_scroll_pagination/example#custom-layout).

- **API-agnostic**: By letting you in complete charge of your API calls, **Infinite Scroll Pagination** works with any [pagination strategy](https://nordicapis.com/everything-you-need-to-know-about-api-pagination/).

- **Highly customizable**: You can change everything. Provide your own progress, error and empty list indicators. Too lazy to change? The defaults will cover you.

- **Extensible**: Seamless integration with [pull-to-refresh](https://pub.dev/packages/infinite_scroll_pagination/example#pull-to-refresh), [searching, filtering and sorting](https://pub.dev/packages/infinite_scroll_pagination/example#searchingfilteringsorting).

- **Listen to state changes**: In addition to displaying widgets indicating the current status, such as progress and error indicators, you can also [use a listener](https://pub.dev/packages/infinite_scroll_pagination/example#listening-to-state-changes) to display dialogs/snackbars/toasts or execute any other action.

## How It Works

Everything lies around the [PagedDataSource](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource-class.html) class. You're expected to subclass it and provide your own implementation for [fetchItems](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/fetchItems.html). You can do whatever you want in there, from directly calling a remote API to sending an event to a BLoC. Once you have your items *or* an error, you have two options:
1. Manually change the values of [itemList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/itemList.html), [error](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/error.html), [nextPageKey](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/nextPageKey.html) and then call [notifyListeners](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html).
2. Use one of the convenience functions to do the above for you: [notifyError](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/notifyError.html),
[notifyNewPage](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/notifyNewPage.html) or [notifyChange](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/notifyChange.html).

Then, provide an instance of your  [PagedDataSource](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource-class.html) subclass along with an instance of a [PagedChildBuilderDelegate](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedChildBuilderDelegate-class.html) to one of our paged widgets and you're done.

## API Overview

<p align="center">
	<img src="https://raw.githubusercontent.com/EdsonBueno/infinite_scroll_pagination/master/docs/assets/api-diagram.png" alt="API Diagram" />
</p>

## Motivation

Flutter indeed [makes our job way easier](https://flutter.dev/docs/resources/inside-flutter#infinite-scrolling) than other toolkits when talking about **infinite scrolling**. It's when we combine that with pagination and lazy fetching that things get complicated.

[ListView.builder](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html) *builds* your items on demand, but it doesn't help you with fetching them or displaying status indicators.

Your listing has many possible statuses: first page loading, first page error, subsequent page loadings, subsequent page errors, empty list and completed list. **Infinite Scroll Pagination** takes care of orchestrating between them, rendering each one and letting you know when more data is needed.

## Troubleshooting

If you're facing a problem using this package, run through the items below and see if it helps:

- When you successfully fetched your first page, did you remember to initialize your [itemList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/itemList.html) with an empty array before trying to add new items to it? Keep in mind that [itemList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/itemList.html) initial value is `null`.
- Did you specify the generic types for the package's classes you're using? For example: `PagedListView<int, CharacterSummary>`.
- If you've changed the values of [itemList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/itemList.html), [error](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/error.html) and/or [nextPageKey](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/nextPageKey.html) by yourself, did you remember to call [notifyListeners](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedDataSource/notifyListeners.html) afterward?