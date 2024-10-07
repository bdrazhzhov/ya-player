class Promotion {
  final String title;
  final String? subtitle;
  final String? heading;
  final String image;
  final String? cover;
  final String url;

  Promotion({
    required this.title,
    this.subtitle,
    this.heading,
    required this.image,
    this.cover,
    required this.url
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      title: json['title'],
      subtitle: json['subtitle'],
      heading: json['heading'],
      image: json['image'],
      cover: json['cover'],
      url: json['url']
    );
  }
}
