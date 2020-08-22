import 'package:breaking_bapp/character_summary.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterSliverGridDataSource
    extends PagedDataSource<int, CharacterSummary> {
  CharacterSliverGridDataSource({
    @required this.onPageRequested,
  }) : super(0);

  final ValueChanged<int> onPageRequested;

  @override
  void fetchItems(int pageKey) => onPageRequested(pageKey);
}
