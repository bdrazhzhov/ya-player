import '/models/music_api/track.dart';

import 'album.dart';
import 'artist.dart';

class PodcastEpisode extends Track {
  PodcastEpisode(
    super.id,
    super.title,
    super.version,
    super.duration,
    super.artists,
    super.albums,
    super.coverUri,
    super.ogImage,
    super.batchId,
    super.pubDate,
    super.isAvailable,
    super.type,
    super.trackParameters,
    super.chart,
    super.lyricsInfo,
    super.isLiked,
  );

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    List<ArtistBase> artists = [];
    json['artists'].forEach((item) {
      artists.add(ArtistBase.fromJson(item));
    });

    List<Album> albums = [];
    json['albums'].forEach((item) {
      albums.add(Album.fromJson(item));
    });

    Duration? duration;
    if(json['durationMs'] != null) {
      duration = Duration(milliseconds: json['durationMs']);
    }

    return PodcastEpisode(
      json['id'],
      json['title'],
      null,
      duration,
      artists,
      albums,
      json['coverUri'] ?? '',
      json['ogImage'],
      '',
      DateTime.tryParse(json['pubDate'] ?? ''),
      json['isAvailable'] ?? false,
      TrackType.podcast,
      null,
      null,
      null,
      json['isLiked'],
    );
  }
}
