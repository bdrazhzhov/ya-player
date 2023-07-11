import 'package:ya_player/models/music_api/album.dart';

import 'artist.dart';

class Track {
  final int id;
  final String title;
  final String? version;
  final Duration duration;
  final List<Artist> artists;
  final List<Album> albums;
  final String coverUri;
  final String ogImage;
  final String batchId;

  Track(this.id, this.title, this.version, this.duration, this.artists,
      this.albums, this.coverUri, this.ogImage, this.batchId);

  int get firstAlbumId => albums.first.id;

  factory Track.fromJson(Map<String, dynamic> json, String batchId) {
    final track = json['id'] != null ? json : json['track'];
    final duration = Duration(milliseconds: track['durationMs']);
    List<Artist> artists = [];
    track['artists'].forEach((item){
      artists.add(Artist.fromJson(item));
    });
    List<Album> albums = [];
    track['albums'].forEach((item){
      albums.add(Album.fromJson(item));
    });

    return Track(int.parse(track['id']), track['title'], track['version'], duration,
        artists, albums, track['coverUri'], track['ogImage'], batchId);
  }
}

class TrackParameters {
  final int bpm;
  final int hue;
  final double energy;

  TrackParameters(this.bpm, this.hue, this.energy);

  factory TrackParameters.fromJson(Map<String, dynamic> json) {
    return TrackParameters(json['bpm'], json['hue'], json['energy']);
  }
}
