import 'artist.dart';

class Podcast {
  final int id;
  final String title;
  final String ogImage;
  final int trackCount;
  final int? likesCount;
  final List<ArtistBase> artists;
  final bool? isAvailable;
  final String? shortDescription;
  final String? description;

  Podcast(this.id, this.title, this.ogImage, this.trackCount,
      this.likesCount, this.artists, this.isAvailable,
      this.shortDescription, this.description);

  factory Podcast.fromJson(Map<String, dynamic> json) {
    final List<ArtistBase> artists = [];
    json['artists'].forEach((artistJson) => ArtistBase.fromJson(artistJson));

    return Podcast(json['id'], json['title'], json['ogImage'],
        json['trackCount'], json['likesCount'], artists, json['isAvailable'],
        json['shortDescription'], json['description']);
  }
}
