import 'artist.dart';

enum PodcastType {podcast, audiobook}

class Podcast {
  final int id;
  final PodcastType type;
  final String title;
  final String image;
  final int tracksCount;
  final int? likesCount;
  final List<ArtistBase> artists;
  final bool? isAvailable;
  final String? shortDescription;
  final String? description;

  Podcast({
    required this.id,
    required this.type,
    required this.title,
    required this.image,
    required this.tracksCount,
    this.likesCount,
    required this.artists,
    this.isAvailable,
    this.shortDescription,
    this.description
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if(data['data'] != null && data['data']['podcast'] != null) data = data['data']['podcast'];

    final List<ArtistBase> artists = [];
    data['artists'].forEach((artistJson) => artists.add(ArtistBase.fromJson(artistJson)));
    final type = data['type'] == 'audiobook' ? PodcastType.audiobook : PodcastType.podcast;

    return Podcast(
      id: data['id'],
      type: type,
      title: data['title'],
      image: data['ogImage'],
      tracksCount: data['trackCount'],
      likesCount: data['likesCount'],
      isAvailable: data['isAvailable'],
      shortDescription: data['shortDescription'] ?? json['shortDescription'],
      description: data['description'] ?? json['description'],
      artists: artists
    );
  }
}
