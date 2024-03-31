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
  final PagingController<int, Photo> _pagingController = PagingController(
    firstPageKey: 1,
  );
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await RemoteApi.getPhotos(pageKey);

      final isLastPage = newItems.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.passthrough,
        children: [
          PagedPageView<int, Photo>(
            pageController: _pageController,
            pagingController: _pagingController,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.black38,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: ListenableBuilder(
                      listenable: _pageController,
                      builder: (context, _) {
                        if (_pageController.positions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '${_pageController.page?.round()} / ${_pagingController.itemList?.length ?? 0}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
}
