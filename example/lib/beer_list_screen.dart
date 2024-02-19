import 'package:brewtiful/samples/beer_list_view.dart';
import 'package:brewtiful/samples/beer_masonry_grid.dart';
import 'package:brewtiful/samples/beer_page_view.dart';
import 'package:brewtiful/samples/beer_sliver_grid.dart';
import 'package:brewtiful/samples/beer_sliver_list.dart';
import 'package:flutter/material.dart';

class BeerListScreen extends StatefulWidget {
  const BeerListScreen({super.key});

  @override
  State<BeerListScreen> createState() => _BeerListScreenState();
}

class _BeerListScreenState extends State<BeerListScreen> {
  int _selectedBottomNavigationIndex = 0;

  final List<_BottomNavigationItem> _bottomNavigationItems = [
    _BottomNavigationItem(
      label: 'Refresh',
      iconData: Icons.refresh,
      widgetBuilder: (context) => const BeerListView(),
    ),
    _BottomNavigationItem(
      label: 'Search',
      iconData: Icons.search,
      widgetBuilder: (context) => const BeerSliverList(),
    ),
    _BottomNavigationItem(
      label: 'Grid',
      iconData: Icons.grid_on,
      widgetBuilder: (context) => const BeerSliverGrid(),
    ),
    _BottomNavigationItem(
      label: 'MasonryGrid',
      iconData: Icons.view_quilt,
      widgetBuilder: (context) => const BeerMasonryGrid(),
    ),
    _BottomNavigationItem(
      label: 'PageView',
      iconData: Icons.fullscreen,
      widgetBuilder: (context) => const BeerPageView(),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Beers'),
        ),
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedBottomNavigationIndex,
          type: BottomNavigationBarType.fixed,
          items: _bottomNavigationItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.iconData),
                  label: item.label,
                ),
              )
              .toList(),
          onTap: (newIndex) => setState(
            () => _selectedBottomNavigationIndex = newIndex,
          ),
        ),
        body: IndexedStack(
          index: _selectedBottomNavigationIndex,
          children: _bottomNavigationItems
              .map(
                (item) => item.widgetBuilder(context),
              )
              .toList(),
        ),
      );
}

class _BottomNavigationItem {
  const _BottomNavigationItem({
    required this.label,
    required this.iconData,
    required this.widgetBuilder,
  });

  final String label;
  final IconData iconData;
  final WidgetBuilder widgetBuilder;
}
