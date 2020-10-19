## 2.2.0+1

* Constraint the Flutter SDK dependency to a minimum version of 1.22.0.

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