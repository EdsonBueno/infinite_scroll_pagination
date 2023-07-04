import 'package:breaking_bapp/remote/beer_summary.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// List item representing a single Beer with its image and name.
class BeerListItem extends StatelessWidget {
  const BeerListItem({
    required this.beer,
    Key? key,
  }) : super(key: key);

  final BeerSummary beer;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(beer.imageUrl),
        ),
        title: Text(beer.name),
      );
}
