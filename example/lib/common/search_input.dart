import 'package:flutter/material.dart';

class SearchInputSliver extends StatefulWidget {
  const SearchInputSliver({
    super.key,
    this.onChanged,
    this.debounceTime,
    required this.getSuggestions,
  });

  final ValueChanged<String>? onChanged;
  final Duration? debounceTime;
  final List<String> Function(String) getSuggestions;

  @override
  State<SearchInputSliver> createState() => _SearchInputSliverState();
}

class _SearchInputSliverState extends State<SearchInputSliver> {
  final SearchController _searchController = SearchController();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SearchAnchor(
              searchController: _searchController,
              viewOnSubmitted: (value) {
                widget.onChanged?.call(value);
                _searchController.closeView(value);
              },
              suggestionsBuilder: (context, controller) =>
                  widget.getSuggestions(controller.text).map(
                        (suggestion) => ListTile(
                          title: Text(suggestion),
                          onTap: () {
                            controller.closeView(suggestion);
                            widget.onChanged?.call(suggestion);
                          },
                        ),
                      ),
              viewShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              builder: (context, controller) => SearchBar(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: controller,
                hintText: 'Search...',
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      );
}
