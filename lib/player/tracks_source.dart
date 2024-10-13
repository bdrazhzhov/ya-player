import 'package:equatable/equatable.dart';
import 'package:ya_player/models/music_api/artist_info.dart';

import '/models/music_api/playlist.dart';
import '/models/music_api/album.dart';
import '/models/music_api/track.dart';

enum TracksSourceType { likedTracks, album, artist, playlist }
final tracksSourceStrings = Map.unmodifiable(<TracksSourceType,String>{
  TracksSourceType.likedTracks: 'desktop_win-own_tracks-track-default',
  TracksSourceType.album: 'desktop_win-album-track-default',
  TracksSourceType.artist: 'desktop_win-artist-track-default',
  TracksSourceType.playlist: 'desktop_win-own_playlist-track-default',
});

class TracksSource extends Equatable {
  final TracksSourceType sourceType;
  final Object? source;
  final int? id;

  const TracksSource({required this.sourceType,
    required this.source, this.id});

  @override
  List<Object?> get props => [sourceType, id];

  Iterable<Track> getTracks() {
    switch(sourceType) {
      case TracksSourceType.likedTracks:
        return source as Iterable<Track>;
      case TracksSourceType.album:
        return (source as AlbumWithTracks).tracks;
      case TracksSourceType.artist:
        return (source as ArtistInfo).popularTracks;
      case TracksSourceType.playlist:
        return (source as Playlist).tracks;
    }
  }
}
