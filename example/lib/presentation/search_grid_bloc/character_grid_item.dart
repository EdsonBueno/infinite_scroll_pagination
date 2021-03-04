import 'package:breaking_bapp/character_summary.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CharacterGridItem extends StatelessWidget {
  const CharacterGridItem({
    required this.character,
    Key? key,
  }) : super(key: key);
  final CharacterSummary character;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: character.pictureUrl,
      );
}
