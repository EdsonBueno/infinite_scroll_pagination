import 'package:flutter/foundation.dart';

/// Summarized information of a character.
class CharacterSummary {
  CharacterSummary({
    @required this.id,
    @required this.name,
    @required this.pictureUrl,
  })  : assert(id != null),
        assert(name != null),
        assert(pictureUrl != null);

  factory CharacterSummary.fromJson(Map<String, dynamic> json) =>
      CharacterSummary(
        id: json['char_id'],
        name: json['name'],
        pictureUrl: json['img'],
      );

  final int id;
  final String name;
  final String pictureUrl;
}
