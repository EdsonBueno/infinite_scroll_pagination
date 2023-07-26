import 'package:flutter/material.dart';

class FirstPageProgressIndicator extends StatelessWidget {
  const FirstPageProgressIndicator({
    Key? key,
    this.adaptive = false,
    this.child,
  }) : super(key: key);
  final bool adaptive;
  final Widget? child;
  @override
  Widget build(BuildContext context) =>
      child ??
      Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: adaptive
              ? const CircularProgressIndicator.adaptive()
              : const CircularProgressIndicator(),
        ),
      );
}
