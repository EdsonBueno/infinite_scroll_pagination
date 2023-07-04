/// Summarized information of a beer.
class BeerSummary {
  BeerSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory BeerSummary.fromJson(Map<String, dynamic> json) => BeerSummary(
        id: json['id'],
        name: json['name'],
        imageUrl: json['image_url'],
      );

  final int id;
  final String name;
  final String imageUrl;
}
