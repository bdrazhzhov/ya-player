import 'podcast.dart';

class PodcastEpisode {
  final int id;
  final String title;
  final Duration? duration;
  final bool? isAvailable;
  final String? shortDescription;
  final DateTime? pubDate;
  final List<Podcast> albums;

  PodcastEpisode(this.id, this.title, this.duration, this.isAvailable,
      this.shortDescription, this.pubDate, this.albums);

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    List<Podcast> albums = [];
    json['albums'].forEach((podcast) => albums.add(Podcast.fromJson(podcast)));

    Duration? duration;
    if(json['durationMs'] != null) {
      duration = Duration(milliseconds: json['durationMs']);
    }

    return PodcastEpisode(json['id'], json['title'], duration, json['isAvailable'],
        json['shortDescription'], DateTime.tryParse(json['pubDate'] ?? ''), albums);
  }
}