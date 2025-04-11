import '/models/music_api/track.dart';
import '/models/music_api/can_be_played.dart';

import 'podcast.dart';

class PodcastEpisode implements CanBePlayed {
  @override
  final String id;
  @override
  final String title;
  @override
  final Duration? duration;
  @override
  final bool isAvailable;
  final String? shortDescription;
  final DateTime? pubDate;
  final List<Podcast> albums;
  @override
  final String? coverUri;

  PodcastEpisode(this.id, this.title, this.duration, this.isAvailable,
      this.shortDescription, this.pubDate, this.albums, this.coverUri);

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    List<Podcast> albums = [];
    json['albums'].forEach((podcast) => albums.add(Podcast.fromJson(podcast)));

    Duration? duration;
    if(json['durationMs'] != null) {
      duration = Duration(milliseconds: json['durationMs']);
    }

    return PodcastEpisode(
      json['id'],
      json['title'],
      duration,
      json['isAvailable'] ?? json['available'],
      json['shortDescription'],
      DateTime.tryParse(json['pubDate'] ?? ''),
      albums,
      json['coverUri'] ?? json['ogImage']
    );
  }

  @override
  String get artist => '';

  @override
  ChartItem? get chart => null;

  @override
  String? get version => null;

  @override
  String get albumName => '';

  @override
  String get fullId => '$id:${albums.first.id}';
}