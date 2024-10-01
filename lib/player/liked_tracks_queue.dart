import '../models/music_api/queue.dart';
import '../music_api.dart';
import 'playback_queue_base.dart';
import '../models/music_api/track.dart';
import '../services/service_locator.dart';

class LikedTracksQueue extends PlaybackQueueBase
{
  static const String _queueName = 'desktop_win-own_tracks-track-default';
  final _musicApi = getIt<MusicApi>();
  String? _id;

  LikedTracksQueue({required super.tracks});

  @override
  Future<Track?> moveTo(int index) async {
    Track? track = await super.moveTo(index);

    if(_id == null)
    {
      final tracksInQueue = tracks.map((track) => QueueTrack(
          track.id.toString(),
          track.albums.first.id.toString(),
          _queueName
      )).toList();
      _id = await _musicApi.createQueueForLikedTracks(tracksInQueue, currentIndex);
    }

    return track;
  }
}