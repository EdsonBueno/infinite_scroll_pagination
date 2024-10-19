import 'package:infinite_example/remote/item.dart';
import 'package:infinite_example/remote/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PageViewScreen extends StatefulWidget {
  const PageViewScreen({super.key});

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  final PageController _pageController = PageController();

  PagingState<int, Photo> _state = PagingState();

  void fetchNextPage() async {
    if (_state.isLoading) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _state = _state.copyWith(isLoading: true, error: null);
      });
    });

    try {
      final newKey = (_state.keys?.last ?? 0) + 1;
      final newItems = await RemoteApi.getPhotos(newKey);
      final isLastPage = newItems.isEmpty;

      setState(() {
        _state = _state.copyWith(
          pages: [
            ...?_state.pages,
            newItems,
          ],
          keys: [
            ...?_state.keys,
            newKey,
          ],
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
            builder: (context, _) {
              return Row(
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
              );
            },
          ),
        ),
      ],
    );
  }
}
