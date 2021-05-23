## 3.0.1+1

* Adds [Flutter Favorite](https://flutter.dev/docs/development/packages-and-plugins/favorites) status to the README.

## 3.0.1

* Fixes code formatting in ListenableListener.
* Updates [sliver_tools](https://pub.dev/packages/sliver_tools) dependency.
* Adds new unit tests.

## 3.0.0

* Promotes null safety to stable release.
* Migrates example project to null safety.
* Migrates code samples to null safety.

## 3.0.0-nullsafety.0

* Migrates to null safety.

## 2.3.0

* Adds an [alternative constructor](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController/PagingController.fromValue.html) to [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html) receiving an initial [PagingState](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingState-class.html).
* Changes Cookbook file name.
* Updates LICENSE file.

## 2.2.4

* Fixes new page requests happening before the end of the current frame.

## 2.2.3

* Fixes a bug in which manually resetting to a previous page would stop requesting subsequent pages.

## 2.2.2

* Adds a condition to avoid requesting the first page when there are preloaded items.

## 2.2.1

* Improves the error message displayed when calling a disposed [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html).
* Adds `shrinkWrapFirstPageIndicators` property to [PagedSliverList](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverList-class.html), [PagedSliverGrid](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverGrid-class.html) and [PagedSliverBuilder](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedSliverBuilder-class.html).
* Fixes separator being displayed on completed lists.

## 2.2.0+1

* Constraints the Flutter SDK dependency to a minimum version of 1.22.0.

## 2.2.0

* Adds new constructor parameters from [ScrollView](https://api.flutter.dev/flutter/widgets/ScrollView-class.html) to [PagedListView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedListView-class.html) and [PagedGridView](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedGridView-class.html).

## 2.1.0+1

* Adds link to [raywenderlich.com tutorial](https://www.raywenderlich.com/265121/infinite-scrolling-pagination-in-flutter).
* Changes examples to async/await.

## 2.1.0

* Adds [noMoreItemsIndicatorBuilder](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedChildBuilderDelegate/noMoreItemsIndicatorBuilder.html) to [PagedChildBuilderDelegate](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagedChildBuilderDelegate-class.html).
* Adds properties to both grid widgets to let you choose whether you want to display the progress, error and completed listing indicators as grid items or if you want to put them below the grid, as is in the list widgets.

## 2.0.1

* Fixes [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html) not calling its status listeners.

## 2.0.0

* **BREAKING CHANGE**: Replaces [PagedDataSource](https://pub.dev/documentation/infinite_scroll_pagination/1.1.1/infinite_scroll_pagination/PagedDataSource-class.html) and [PagedStateChangeListener](https://pub.dev/documentation/infinite_scroll_pagination/1.1.1/infinite_scroll_pagination/PagedStateChangeListener-class.html) with [PagingController](https://pub.dev/documentation/infinite_scroll_pagination/latest/infinite_scroll_pagination/PagingController-class.html), favoring composition over inheritance.

## 1.1.1

* Removes scroll from first page progress indicator, first page error indicator and no items found indicator.

## 1.1.0

* Adds [PagedStateChangeListener](https://pub.dev/documentation/infinite_scroll_pagination/1.1.0/infinite_scroll_pagination/PagedStateChangeListener-class.html).

## 1.0.0+2

* Changes README images reference URL.
* Adds documentation to PagedDataSource properties.

## 1.0.0+1

* Adds images to README.md.

## 1.0.0

* Initial release.