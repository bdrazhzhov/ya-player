import 'package:flutter/cupertino.dart';
import 'package:ya_player/models/music_api/artist_info.dart';

import '/player/tracks_source.dart';
import '/models/music_api/playlist.dart';
import '/models/music_api/track.dart';
import '/models/music_api/album.dart';
import '/models/music_api/queue.dart';

class QueueFactory {
  @factory
  static Queue create({required TracksSource tracksSource,
    required int currentIndex})
  {
    final QueueContext context;
    final Iterable<QueueTrack> queueTracks;
    
    switch(tracksSource.sourceType) {
      case TracksSourceType.likedTracks:
        (context, queueTracks) = _forLikedTracks(tracksSource.source as Iterable<Track>);
      case TracksSourceType.album:
        (context, queueTracks) = _forAlbum(tracksSource.source as AlbumWithTracks);
      case TracksSourceType.artist:
        (context, queueTracks) = _forArtist(tracksSource.source as ArtistInfo);
      case TracksSourceType.playlist:
        (context, queueTracks) = _forPlaylist(tracksSource.source as Playlist);
      case TracksSourceType.radio:
        context = QueueContext(description: '', id: '', type: '');
        queueTracks = [];
    }

    return Queue(
      context: context,
      tracks: queueTracks,
      currentIndex: currentIndex,
      isInteractive: true
    );
  }

  static (QueueContext, Iterable<QueueTrack>) _forLikedTracks(Iterable<Track> tracks) {
    final context = QueueContext(description: '', id: 'fonoteca', type: 'my_music');
    final List<QueueTrack> queueTracks = _createQueueTracks(
        tracks, tracksSourceStrings[TracksSourceType.likedTracks]);

    return (context, queueTracks);
  }

  static (QueueContext, List<QueueTrack>) _forAlbum(AlbumWithTracks albumWithTracks) {
    final context = QueueContext(
        description: albumWithTracks.album.title,
        id: albumWithTracks.album.id.toString(),
        type: 'album'
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
        albumWithTracks.tracks, tracksSourceStrings[TracksSourceType.album]);

    return (context, queueTracks);
  }

  static (QueueContext, Iterable<QueueTrack>) _forArtist(ArtistInfo artistWithTracks) {
    final context = QueueContext(
        description: artistWithTracks.artist.name,
        id: artistWithTracks.artist.id.toString(),
        type: 'artist'
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
        artistWithTracks.popularTracks,
        tracksSourceStrings[TracksSourceType.artist]);

    return (context, queueTracks);
  }

  static (QueueContext, Iterable<QueueTrack>) _forPlaylist(Playlist playlist) {
    final context = QueueContext(
        description: playlist.title,
        id: '${playlist.uid}:${playlist.kind}',
        type: 'my_music'
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
        playlist.tracks, tracksSourceStrings[TracksSourceType.playlist]);

    return (context, queueTracks);
  }

  static List<QueueTrack> _createQueueTracks(Iterable<Track> tracks, from) {
    return tracks.map(
            (track) => QueueTrack(
            track.id.toString(),
            track.albums.first.id.toString(),
            from
        )
    ).toList();
  }
}
