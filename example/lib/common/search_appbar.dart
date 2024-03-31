import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.searchTerm,
    required this.onSearch,
  });

  final String? searchTerm;
  final ValueChanged<String> onSearch;

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearchMode = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isSearchMode
          ? AppBar(
              title: TextFormField(
                initialValue: widget.searchTerm,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: Theme.of(context).textTheme.titleLarge,
                onFieldSubmitted: (value) {
                  widget.onSearch(value);
                  setState(() => _isSearchMode = false);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isSearchMode = false),
                ),
              ],
            )
          : AppBar(
              title: const Text('Photos'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _isSearchMode = true),
                ),
              ],
            ),
    );
  }
}
