import 'album.dart';

class FeedPromotions {
  final String promoId;
  final String title;
  final String subtitle;
  final String heading;
  final String category;
  final String titleUrl;
  final String subtitleUrl;
  final String description;
  final String background;
  final String imagePosition;
  final String promotionType;
  final String startDate;
  final List<Album> albums;

  FeedPromotions({
    required this.promoId,
    required this.title,
    required this.subtitle,
    required this.heading,
    required this.category,
    required this.titleUrl,
    required this.subtitleUrl,
    required this.description,
    required this.background,
    required this.imagePosition,
    required this.promotionType,
    required this.startDate,
    required this.albums,
  });

  factory FeedPromotions.fromJson(Map<String, dynamic> json) {
    List<Album> albums = [];
    json['albums'].forEach((item) => albums.add(Album.fromJson(item)));

    return FeedPromotions(
      promoId: json['promoId'],
      title: json['title'],
      subtitle: json['subtitle'],
      heading: json['heading'],
      category: json['category'],
      titleUrl: json['titleUrl'],
      subtitleUrl: json['subtitleUrl'],
      description: json['description'],
      background: json['background'],
      imagePosition: json['imagePosition'],
      promotionType: json['promotionType'],
      startDate: json['startDate'],
      albums: albums
    );
  }
}
