import 'package:ya_player/models/music_api/artist_info.dart';
import 'package:ya_player/models/music_api/station.dart';

import '/services/music_api.dart';
import '/services/service_locator.dart';
import '/models/music_api/playlist.dart';
import '/models/music_api/track.dart';
import '/models/music_api/album.dart';
import '/models/music_api/queue.dart';

class QueueFactory {
  static final _musicApi = getIt<MusicApi>();

  static Future<Queue> create({required Object tracksSource, int? currentIndex}) async {
    final QueueContext context;
    final Iterable<QueueTrack> queueTracks;
    String? from;

    switch (tracksSource) {
      case List<Track> tracks:
        (context, queueTracks) = _forLikedTracks(tracks);
      case AlbumWithTracks albumWithTracks:
        (context, queueTracks) = _forAlbum(albumWithTracks);
      case ArtistInfo artist:
        (context, queueTracks) = _forArtist(artist);
      case Playlist playlist:
        (context, queueTracks) = _forPlaylist(playlist);
      case (Station station, Iterable<Track> tracks):
        (context, queueTracks) = _forStation(station, tracks);
        from = station.from;
      default:
        context = const QueueContext(description: '', id: '', type: '');
        queueTracks = [];
    }

    return _musicApi.createQueue(
        context: context,
        tracks: queueTracks,
        currentIndex: currentIndex,
        isInteractive: true,
        from: from);
  }

  static (QueueContext, Iterable<QueueTrack>) _forLikedTracks(Iterable<Track> tracks) {
    const context = QueueContext(description: '', id: 'fonoteca', type: 'my_music');
    final List<QueueTrack> queueTracks = _createQueueTracks(
      tracks,
      'desktop_win-own_tracks-track-default',
    );

    return (context, queueTracks);
  }

  static (QueueContext, List<QueueTrack>) _forAlbum(AlbumWithTracks albumWithTracks) {
    final context = QueueContext(
      description: albumWithTracks.album.title,
      id: albumWithTracks.album.id.toString(),
      type: 'album',
    );

    final List<QueueTrack> queueTracks =
        _createQueueTracks(albumWithTracks.tracks, 'desktop_win-album-track-default');

    return (context, queueTracks);
  }

  static (QueueContext, Iterable<QueueTrack>) _forArtist(ArtistInfo artistWithTracks) {
    final context = QueueContext(
      description: artistWithTracks.artist.name,
      id: artistWithTracks.artist.id.toString(),
      type: 'artist',
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
      artistWithTracks.popularTracks,
      'desktop_win-artist-track-default',
    );

    return (context, queueTracks);
  }

  static (QueueContext, Iterable<QueueTrack>) _forStation(Station station, Iterable<Track> tracks) {
    final context = QueueContext(
      description: station.name,
      id: station.id.toString(),
      type: 'radio',
    );
    final List<QueueTrack> queueTracks = _createQueueTracks(tracks, station.from);

    return (context, queueTracks);
  }

  static (QueueContext, Iterable<QueueTrack>) _forPlaylist(Playlist playlist) {
    final context = QueueContext(
      description: playlist.title,
      id: '${playlist.uid}:${playlist.kind}',
      type: 'my_music',
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
      playlist.tracks,
      'desktop_win-own_playlist-track-default',
    );

    return (context, queueTracks);
  }

  static List<QueueTrack> _createQueueTracks(Iterable<Track> tracks, from) {
    return tracks
        .map((track) => QueueTrack(
              track.id,
              track.albums.first.id.toString(),
              from,
            ))
        .toList();
  }
}
