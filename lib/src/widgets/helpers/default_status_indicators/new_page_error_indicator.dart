import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/widgets/helpers/default_status_indicators/footer_tile.dart';

class NewPageErrorIndicator extends StatelessWidget {
  const NewPageErrorIndicator({
    Key? key,
    this.onTap,
    this.errorMessage = 'Something went wrong. Tap to try again.',
  }) : super(key: key);

  final String errorMessage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: FooterTile(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 4,
              ),
              const Icon(
                Icons.refresh,
                size: 16,
              ),
            ],
          ),
        ),
      );
}
