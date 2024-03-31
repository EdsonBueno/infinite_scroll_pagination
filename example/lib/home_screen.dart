import 'package:infinite_example/samples/list_view.dart';
import 'package:infinite_example/samples/page_view.dart';
import 'package:infinite_example/samples/sliver_grid.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedBottomNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<_BottomNavigationItem> bottomNavigationItems = [
      _BottomNavigationItem(
        label: 'List',
        iconData: Icons.list,
        widgetBuilder: (context) => const ListViewScreen(),
      ),
      _BottomNavigationItem(
        label: 'Grid',
        iconData: Icons.view_quilt,
        widgetBuilder: (context) => const SliverGridScreen(),
      ),
      _BottomNavigationItem(
        label: 'PageView',
        iconData: Icons.auto_stories,
        widgetBuilder: (context) => const PageViewScreen(),
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavigationIndex,
        type: BottomNavigationBarType.fixed,
        items: bottomNavigationItems
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
      body: ScaffoldMessenger(
        child: IndexedStack(
          index: _selectedBottomNavigationIndex,
          children: bottomNavigationItems
              .map((item) => item.widgetBuilder(context))
              .toList(),
        ),
      ),
    );
  }
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
