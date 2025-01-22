import 'track.dart';

class Playlist {
  final int kind;
  final String title;
  final int uid;
  final String? description;
  final String ownerName;
  final Duration duration;
  final String? image;
  final int tracksCount;
  final List<Track> tracks;
  final List<Playlist> similarPlaylists;

  Playlist({
    required this.kind,
    required this.title,
    required this.uid,
    this.description,
    required this.ownerName,
    required this.duration,
    required this.image,
    required this.tracksCount,
    required this.tracks,
    required this.similarPlaylists
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    String? image;
    if(json['cover'] != null && json['cover']['uri'] != null) {
      image = json['cover']['uri'];
    }
    else {
      image = json['ogImage'];
    }

    List<Track> tracks = [];
    if(json['tracks'] != null) {
      json['tracks'].forEach((t) => tracks.add(Track.fromJson(t, '')));
    }

    List<Playlist> similarPlaylists = [];
    if(json['similarPlaylists'] != null) {
      json['similarPlaylists'].forEach((p) => similarPlaylists.add(Playlist.fromJson(p)));
    }

    return Playlist(kind: json['kind'] ?? 0, title: json['title'],
      uid: json['uid'] ?? 0, description: json['description'],
      ownerName: json['owner']?['name'] ?? '',
      duration: Duration(milliseconds: json['durationMs'] ?? 0),
      tracksCount: json['trackCount'] ?? 0, image: image, tracks: tracks,
      similarPlaylists: similarPlaylists
    );
  }
}
