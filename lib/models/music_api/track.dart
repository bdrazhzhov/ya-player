import 'package:equatable/equatable.dart';

import 'album.dart';
import 'artist.dart';

enum TrackType { music, podcast, audiobook }

class Track extends Equatable {
  final int id;
  final String title;
  final String? version;
  final Duration? duration;
  final List<ArtistBase> artists;
  final List<Album> albums;
  final String? coverUri;
  final String? ogImage;
  final String batchId;
  final DateTime? pubDate;
  final bool isAvailable;
  final TrackType type;
  final TrackParameters? trackParameters;
  late final String artist;

  Track(this.id, this.title, this.version, this.duration, this.artists,
      this.albums, this.coverUri, this.ogImage, this.batchId, this.pubDate,
      this.isAvailable, this.type, this.trackParameters) {
    artist = artists.map((artist) => artist.name).join(', ');
  }

  int get firstAlbumId => albums.first.id;

  static final _trackTypes = {
    'music': TrackType.music,
    'podcast-episode': TrackType.podcast,
    'audiobook': TrackType.podcast
  };

  factory Track.fromJson(Map<String, dynamic> json, String batchId) {
    final track = json['track'] ?? json;
    Duration? duration;
    if(track['durationMs'] != null) {
      duration = Duration(milliseconds: track['durationMs']);
    }
    List<ArtistBase> artists = [];
    track['artists'].forEach((item){
      artists.add(ArtistBase.fromJson(item));
    });
    List<Album> albums = [];
    track['albums'].forEach((item){
      albums.add(Album.fromJson(item));
    });

    final id = json['id'] ?? json['realId'] ?? track['id'] ?? track['realId'];

    DateTime? pubDate;
    if(track['pubDate'] != null) pubDate = DateTime.tryParse(track['pubDate']);

    TrackParameters? trackParameters;
    if(json['trackParameters'] != null) {
      trackParameters = TrackParameters.fromJson(json['trackParameters']);
    }

    return Track(id is String ? int.parse(id) : id,
      track['title'], track['version'], duration, artists, albums,
      track['coverUri'], track['ogImage'], batchId, pubDate, track['available'],
      _trackTypes[track['type'].toString()] ?? TrackType.music, trackParameters
    );
  }

  @override
  List<Object?> get props => [id];
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

class TrackOfList {
  final int id;
  final int albumId;
  final DateTime timestamp;

  TrackOfList(this.id, this.albumId, this.timestamp);

  factory TrackOfList.fromJson(Map<String, dynamic> json) {
    return TrackOfList(json['id'], json['albumId'], DateTime.parse(json['timestamp']));
  }
}
