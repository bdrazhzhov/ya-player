import 'package:equatable/equatable.dart';

import 'artist.dart';
import 'track.dart';

class Album extends Equatable {
  final int id;
  final String title;
  final int? year;
  final DateTime? releaseDate;
  final String coverUri;
  final String ogImage;
  final String genre;
  final int tracksCount;
  final List<ArtistBase> artists;
  final String? description;
  final String? version;
  late final String artist;

  Album(this.id, this.title, this.year, this.releaseDate, this.coverUri,
      this.ogImage, this.genre, this.tracksCount, this.artists,
      this.description, this.version) {
    artist = artists.map((artist) => artist.name).join(', ');
  }

  @override
  List<Object?> get props => [id];
  
  factory Album.fromJson(Map<String, dynamic> json) {
    if(json['album'] != null) {
      json = json['album'];
    }

    List<ArtistBase> artists = [];
    json['artists'].forEach((item) {
      artists.add(ArtistBase.fromJson(item));
    });

    DateTime? releaseDate;
    if(json['releaseDate'] != null) {
      releaseDate = DateTime.parse(json['releaseDate']);
    }

    return Album(json['id'], json['title'], json['year'], releaseDate,
        json['coverUri'], json['ogImage'], json['genre'] ?? '',
        json['trackCount'], artists, json['description'], json['version']);
  }
}

class AlbumWithTracks extends Equatable {
  final Album album;
  final List<Track> tracks;

  const AlbumWithTracks(this.album, this.tracks);

  @override
  List<Object?> get props => [album];

  factory AlbumWithTracks.fromJson(Map<String, dynamic> json) {
    List<Track> tracks = [];

    json['result']['volumes'].first.forEach((trackJson){
      tracks.add(Track.fromJson(trackJson, ''));
    });

    return AlbumWithTracks(Album.fromJson(json['result']), tracks);
  }
}
