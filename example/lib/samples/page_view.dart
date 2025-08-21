import 'package:infinite_example/remote/item.dart';
import 'package:infinite_example/remote/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'list_view.dart';
import 'sliver_grid.dart';

class PageViewScreen extends StatefulWidget {
  const PageViewScreen({super.key});

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  final PageController _pageController = PageController();

  /// This example uses a [PagingState] and [setState] directly to manage the paging state.
  ///
  /// This is the most direct way to use the package.
  /// For a more managed approach, see [ListViewScreen].
  /// For managing your [PagingState] inside your own controller, see [SliverGridScreen].
  PagingState<int, Photo> _state = PagingState();

  void fetchNextPage() async {
    if (_state.isLoading) return;

    setState(() {
      // set loading to true and remove any previous error
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      // in our simple setup, keys are sequential numbers
      final newKey = (_state.keys.lastOrNull ?? 0) + 1;
      // we fetch the next page of items
      final newItems = await RemoteApi.getPhotos(newKey);
      // if the new page is empty, we reached the end
      final isLastPage = newItems.isEmpty;

      setState(() {
        _state = _state.copyWith(
          // append our new page to the existing pages
          pages: [
            ..._state.pages,
            newItems,
          ],
          // append the new key to the existing keys
          keys: [
            ..._state.keys,
            newKey,
          ],
          // signal if we reached the end
          hasNextPage: !isLastPage,
          // set loading back to false
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(
          // in case of an error, we store it in the state
          error: error,
          isLoading: false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        PagedPageView<int, Photo>(
          pageController: _pageController,
          state: _state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => CachedNetworkImage(
              imageUrl: item.thumbnail,
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: 16,
          child: ListenableBuilder(
            listenable: _pageController,
            builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_pageController.hasClients)
                  Material(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.black38,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        '${(_pageController.page ?? 0).round()} / ${_state.items?.length ?? 0}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
