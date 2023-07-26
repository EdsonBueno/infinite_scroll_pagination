import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/footer_tile.dart';

class NewPageProgressIndicator extends StatelessWidget {
  const NewPageProgressIndicator({
    Key? key,
    this.adaptive = false,
    this.child,
  }) : super(key: key);
  final bool adaptive;
  final Widget? child;

  @override
  Widget build(BuildContext context) =>
      child ??
      FooterTile(
        child: adaptive
            ? const CircularProgressIndicator.adaptive()
            : const CircularProgressIndicator(),
      );
}
