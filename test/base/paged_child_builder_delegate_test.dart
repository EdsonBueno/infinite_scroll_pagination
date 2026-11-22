import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef _LayoutBuilder = Widget Function(
  PagingState<int, String> state,
  PagedChildBuilderDelegate<String> builderDelegate,
);

PagingState<int, String> _completed(List<String> items) =>
    PagingState<int, String>(
      pages: [items],
      keys: const [1],
      hasNextPage: false,
    );

class _Tile extends StatefulWidget {
  const _Tile({required super.key, required this.item});

  final String item;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 50, child: Text(widget.item));
}

Future<void> _expectStateKeptOnInsert(
  WidgetTester tester,
  _LayoutBuilder buildLayout,
) async {
  var items = ['A', 'B', 'C'];

  Future<void> pump() => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildLayout(
              _completed(items),
              PagedChildBuilderDelegate<String>(
                itemBuilder: (context, item, index) =>
                    _Tile(key: ValueKey(item), item: item),
                findChildIndexCallback: (key) {
                  final index = items.indexOf((key as ValueKey<String>).value);
                  return index < 0 ? null : index;
                },
              ),
            ),
          ),
        ),
      );

  final finder = find.byKey(const ValueKey('A'), skipOffstage: false);

  await pump();
  final before = tester.state<_TileState>(finder);

  items = ['X', ...items];
  await pump();

  expect(tester.state<_TileState>(finder), same(before));
}

void main() {
  group('findChildIndexCallback keeps item state when an item is inserted', () {
    testWidgets('in PagedListView', (tester) async {
      await _expectStateKeptOnInsert(
        tester,
        (state, builderDelegate) => PagedListView<int, String>(
          state: state,
          fetchNextPage: () {},
          builderDelegate: builderDelegate,
        ),
      );
    });

    testWidgets('in PagedListView.separated', (tester) async {
      await _expectStateKeptOnInsert(
        tester,
        (state, builderDelegate) => PagedListView<int, String>.separated(
          state: state,
          fetchNextPage: () {},
          builderDelegate: builderDelegate,
          separatorBuilder: (context, index) => const Divider(),
        ),
      );
    });

    testWidgets('in PagedGridView', (tester) async {
      await _expectStateKeptOnInsert(
        tester,
        (state, builderDelegate) => PagedGridView<int, String>(
          state: state,
          fetchNextPage: () {},
          builderDelegate: builderDelegate,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
        ),
      );
    });

    testWidgets('in PagedMasonryGridView', (tester) async {
      await _expectStateKeptOnInsert(
        tester,
        (state, builderDelegate) => PagedMasonryGridView<int, String>(
          state: state,
          fetchNextPage: () {},
          builderDelegate: builderDelegate,
          gridDelegateBuilder: (childCount) =>
              const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
        ),
      );
    });

    testWidgets('in PagedPageView', (tester) async {
      await _expectStateKeptOnInsert(
        tester,
        (state, builderDelegate) => PagedPageView<int, String>(
          state: state,
          fetchNextPage: () {},
          builderDelegate: builderDelegate,
          allowImplicitScrolling: true,
        ),
      );
    });
  });
}
