import 'package:infinite_example/remote/item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageListTile extends StatelessWidget {
  const ImageListTile({
    super.key,
    required this.item,
  });

  final Photo item;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(item.thumbnail),
        ),
        title: Text(item.title),
      );
}
