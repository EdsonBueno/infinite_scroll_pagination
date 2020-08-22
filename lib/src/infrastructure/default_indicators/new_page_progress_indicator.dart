import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/default_indicators/footer_tile.dart';

class NewPageProgressIndicator extends StatelessWidget {
  const NewPageProgressIndicator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => const FooterTile(
        child: CircularProgressIndicator(),
      );
}
