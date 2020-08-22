import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CharacterSearchInputSliver extends StatefulWidget {
  const CharacterSearchInputSliver({
    Key key,
    this.onChanged,
    this.debounceTime,
  }) : super(key: key);
  final ValueChanged<String> onChanged;
  final Duration debounceTime;

  @override
  _CharacterSearchInputSliverState createState() =>
      _CharacterSearchInputSliverState();
}

class _CharacterSearchInputSliverState
    extends State<CharacterSearchInputSliver> {
  final StreamController<String> _textChangeStreamController =
      StreamController();
  StreamSubscription _textChangesSubscription;

  @override
  void initState() {
    _textChangesSubscription = _textChangeStreamController.stream
        .debounceTime(
          widget.debounceTime ?? const Duration(seconds: 1),
        )
        .distinct()
        .listen((text) {
      if (widget.onChanged != null) {
        widget.onChanged(text);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Character Name',
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
