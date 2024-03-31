import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SearchInputSliver extends StatefulWidget {
  const SearchInputSliver({
    super.key,
    this.onChanged,
    this.debounceTime,
  });
  final ValueChanged<String>? onChanged;
  final Duration? debounceTime;

  @override
  State<SearchInputSliver> createState() => _SearchInputSliverState();
}

class _SearchInputSliverState extends State<SearchInputSliver> {
  final StreamController<String> _textChangeStreamController =
      StreamController();
  late StreamSubscription _textChangesSubscription;

  @override
  void initState() {
    super.initState();
    _textChangesSubscription = _textChangeStreamController.stream
        .debounceTime(
          widget.debounceTime ??
              const Duration(
                seconds: 1,
              ),
        )
        .distinct()
        .listen((text) {
      final onChanged = widget.onChanged;
      if (onChanged != null) {
        onChanged(text);
      }
    });
  }

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.search,
              ),
              hintText: 'Search...',
            ),
            onChanged: _textChangeStreamController.add,
          ),
        ),
      );

  @override
  void dispose() {
    _textChangeStreamController.close();
    _textChangesSubscription.cancel();
    super.dispose();
  }
}
