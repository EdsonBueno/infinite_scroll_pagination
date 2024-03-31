import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CustomFirstPageError extends StatelessWidget {
  const CustomFirstPageError({
    super.key,
    required this.pagingController,
  });

  final PagingController<Object, Object> pagingController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Something went wrong :(',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (pagingController.error != null) ...[
            const SizedBox(
              height: 16,
            ),
            Text(
              pagingController.error.toString(),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(
            height: 48,
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: pagingController.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNewPageError extends StatelessWidget {
  const CustomNewPageError({
    super.key,
    required this.pagingController,
  });

  final PagingController<Object, Object> pagingController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pagingController.retryLastFailedRequest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We didn\'t catch that. Try again?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const Icon(
              Icons.refresh,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
