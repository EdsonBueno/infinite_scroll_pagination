import 'package:breaking_bapp/samples/character_list_view.dart';
import 'package:breaking_bapp/samples/character_masonry_grid.dart';
import 'package:breaking_bapp/samples/character_page_view.dart';
import 'package:breaking_bapp/samples/character_sliver_grid.dart';
import 'package:breaking_bapp/samples/character_sliver_list.dart';
import 'package:flutter/material.dart';

class CharacterListScreen extends StatefulWidget {
  @override
  _CharacterListScreenState createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  int _selectedBottomNavigationIndex = 0;

  final List<_BottomNavigationItem> _bottomNavigationItems = [
    _BottomNavigationItem(
      label: 'Refresh',
      iconData: Icons.refresh,
      widgetBuilder: (context) => CharacterListView(),
    ),
    _BottomNavigationItem(
      label: 'Search',
      iconData: Icons.search,
      widgetBuilder: (context) => CharacterSliverList(),
    ),
    _BottomNavigationItem(
      label: 'Grid',
      iconData: Icons.grid_on,
      widgetBuilder: (context) => CharacterSliverGrid(),
    ),
    _BottomNavigationItem(
      label: 'MasonryGrid',
      iconData: Icons.view_quilt,
      widgetBuilder: (context) => CharacterMasonryGrid(),
    ),
    _BottomNavigationItem(
      label: 'PageView',
      iconData: Icons.fullscreen,
      widgetBuilder: (context) => CharacterPageView(),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Characters'),
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
