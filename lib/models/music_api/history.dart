import 'album.dart';
import 'artist.dart';
import 'playlist.dart';
import 'track.dart';

class ArtistItem {
  final String id;
  final String name;
  final String coverUri;

  ArtistItem({required this.id, required this.name, required this.coverUri});

  factory ArtistItem.fromJson(Map<String, dynamic> json) {
    return ArtistItem(
      id: json['id'].toString(),
      name: json['name'],
      coverUri: json['cover']['uri'],
    );
  }
}

class NonMusicAlbum {
  final String id;
  final String name;
  final String coverUri;
  final List<ArtistItem> artists;
  final int likesCount;

  NonMusicAlbum({
    required this.id,
    required this.name,
    required this.coverUri,
    required this.artists,
    required this.likesCount,
  });

  factory NonMusicAlbum.fromJson(Map<String, dynamic> json) {
    List<ArtistItem> artists = [];
    json['artists'].forEach((item) {
      artists.add(ArtistItem.fromJson(item));
    });

    final int likesCount = json['likesCount'] ?? 0;
    json = json['album'];
    
    return NonMusicAlbum(
      id: json['id'].toString(),
      name: json['title'],
      coverUri: json['cover']['uri'],
      artists: artists,
      likesCount: likesCount
    );
  }
}

Object getHistoryItem(Map<String, dynamic> json) {
  switch(json['type']) {
    case 'track_item':
      return Track.fromJson(json['data']['track'], '');
    case 'artist_item':
      return Artist.fromJson(json['data']['artist']);
    case 'playlist_item':
      return Playlist.fromJson(json['data']['playlist']);
    case 'album_item':
      return Album.fromJson(json['data']['album']);
    case 'non_music_album_item':
      return NonMusicAlbum.fromJson(json['data']);
    default:
      throw Exception('Unknown history item type');
  }
}
