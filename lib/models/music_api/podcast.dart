import 'album.dart';
import 'artist.dart';

enum PodcastType {podcast, audiobook}

class Podcast extends Album {
  final PodcastType type;
  final String? shortDescription;

  Podcast(
    super.id,
    this.type,
    super.title,
    super.year,
    super.releaseDate,
    super.coverUri,
    super.ogImage,
    super.genre,
    super.tracksCount,
    super.artists,
    super.description,
    this.shortDescription,
    super.version,
  );

  factory Podcast.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if(data['data'] != null && data['data']['podcast'] != null) data = data['data']['podcast'];
    final type = data['type'] == 'audiobook' ? PodcastType.audiobook : PodcastType.podcast;

    final List<ArtistBase> artists = [];
    data['artists']?.forEach((artistJson) => artists.add(ArtistBase.fromJson(artistJson)));

    return Podcast(
      data['id'],
      type,
      data['title'],
      data['year'],
      data['releaseDate'] != null ? DateTime.parse(data['releaseDate']) : null,
      data['ogImage'],
      data['ogImage'],
      data['genre'] ?? '',
      data['trackCount'],
      artists,
      data['description'] ?? '',
      data['shortDescription'] ?? '',
      data['version'],
    );
  }
}
