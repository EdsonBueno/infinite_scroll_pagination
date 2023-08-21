import 'package:flutter/material.dart';

class FirstPageProgressIndicator extends StatelessWidget {
  const FirstPageProgressIndicator({
    Key? key,
    this.adaptive = false,
  }) : super(key: key);

  final bool adaptive;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: adaptive
              ? const CircularProgressIndicator.adaptive()
              : const CircularProgressIndicator(),
        ),
      );
}
