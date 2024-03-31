import 'dart:math';

class Photo {
  Photo({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.width,
    required this.height,
  });

  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnail;
  final int width;
  final int height;

  factory Photo.fromPlaceholderJson(dynamic json) {
    final id = json["thumbnailUrl"].split('/').last;
    final width = Random(id.hashCode ^ 1).nextInt(1000) + 300;
    final height = Random(id.hashCode ^ 2).nextInt(1000) + 300;
    return Photo(
      albumId: json["albumId"],
      id: json["id"],
      title: json["title"],
      url: json["url"],
      thumbnail: 'https://picsum.photos/seed/$id/$width/$height',
      width: width,
      height: height,
    );
  }
}
