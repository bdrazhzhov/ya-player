import 'track.dart';

class Playlist {
  final String title;
  final int tracksCount;
  final String ogImage;
  final List<TrackOfList> trackOfLists;
  final List<Track> tracks = [];

  Playlist(this.title, this.tracksCount, this.ogImage, this.trackOfLists);

  factory Playlist.fromJson(Map<String, dynamic> json) {
    List<TrackOfList> tracks = [];
    json['tracks'].forEach((t) => tracks.add(TrackOfList.fromJson(t)));

    return Playlist(json['title'], json['trackCount'], json['ogImage'], tracks);
  }
}
