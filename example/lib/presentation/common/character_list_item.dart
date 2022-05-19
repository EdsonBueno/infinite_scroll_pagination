import 'package:breaking_bapp/character_summary.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// List item representing a single Character with its photo and name.
class CharacterListItem extends StatelessWidget {
  const CharacterListItem({
    required this.character,
    Key? key,
  }) : super(key: key);

  final CharacterSummary character;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(character.pictureUrl),
        ),
        title: Text(character.name),
      );
}
