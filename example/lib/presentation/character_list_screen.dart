import 'package:breaking_bapp/presentation/pull_to_refresh/character_list_view.dart';
import 'package:breaking_bapp/presentation/search_grid_bloc/character_sliver_grid.dart';
import 'package:breaking_bapp/presentation/search_snackbar/character_sliver_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Fetches and displays a list of characters' summarized info.
class CharacterListScreen extends StatefulWidget {
  @override
  _CharacterListScreenState createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  int _currentBarIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Characters'),
        ),
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBarIndex,
          items: const [
            BottomNavigationBarItem(
              title: Text('Pull to Refresh'),
              icon: Icon(Icons.refresh),
            ),
            BottomNavigationBarItem(
              title: Text('Search/Snackbar'),
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              title: Text('BLoC/Grid/Search'),
              icon: Icon(Icons.grid_on),
            )
          ],
          onTap: (newIndex) => setState(
            () => _currentBarIndex = newIndex,
          ),
        ),
        body: _currentBarIndex == 0
            ? CharacterListView()
            : _currentBarIndex == 1
                ? CharacterSliverList()
                : CharacterSliverGrid(),
      );
}
