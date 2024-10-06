import '/models/music_api/playlist.dart';
import '/models/music_api/artist.dart';
import '/models/music_api/track.dart';
import '/models/music_api/album.dart';
import '/models/music_api/queue.dart';

class QueueFactory {
  static Queue create(Object queueSource, List<Track> tracks, int currentIndex) {
    late final QueueContext context;
    late final List<QueueTrack> queueTracks;

    switch (queueSource) {
      case Album album:
        (context, queueTracks) = _forAlbum(tracks, album);
        break;
      case LikedArtist artist:
        (context, queueTracks) = _forArtist(tracks, artist);
        break;
      case Playlist playlist:
        (context, queueTracks) = _forPlaylist(playlist);
        break;
      default:
        (context, queueTracks) = _forLikedTracks(tracks);
        break;
    }

    return Queue(
      context: context,
      tracks: queueTracks,
      currentIndex: currentIndex,
      isInteractive: true
    );
  }

  static (QueueContext, List<QueueTrack>) _forLikedTracks(List<Track> tracks) {
    final context = QueueContext(description: '', id: 'fonoteca', type: 'my_music');
    final List<QueueTrack> queueTracks = _createQueueTracks(
        tracks, 'desktop_win-own_tracks-track-default');

    return (context, queueTracks);
  }

  static (QueueContext, List<QueueTrack>) _forAlbum(List<Track> tracks, Album album) {
    final context = QueueContext(
        description: album.title,
        id: album.id.toString(),
        type: 'album'
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
        tracks, 'desktop_win-own_tracks-track-default');

    return (context, queueTracks);
  }

  static (QueueContext, List<QueueTrack>) _forArtist(List<Track> tracks, LikedArtist artist) {
    final context = QueueContext(
        description: artist.name,
        id: artist.id.toString(),
        type: 'artist'
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
        tracks, 'desktop_win-artist-track-default');

    return (context, queueTracks);
  }

  static (QueueContext, List<QueueTrack>) _forPlaylist(Playlist playlist) {
    final context = QueueContext(
        description: playlist.title,
        id: '${playlist.uid}:${playlist.kind}',
        type: 'my_music'
    );

    final List<QueueTrack> queueTracks = _createQueueTracks(
        playlist.tracks, 'desktop_win-own_playlist-track-default');

    return (context, queueTracks);
  }

  static List<QueueTrack> _createQueueTracks(List<Track> tracks, from) {
    return tracks.map(
            (track) => QueueTrack(
            track.id.toString(),
            track.albums.first.id.toString(),
            from
        )
    ).toList();
  }
}
