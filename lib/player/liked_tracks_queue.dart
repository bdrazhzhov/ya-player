import '/player/queue/queue_factory.dart';
import '/models/music_api/queue.dart';
import '/music_api.dart';
import 'playback_queue_base.dart';
import '/models/music_api/track.dart';
import '/services/service_locator.dart';

class LikedTracksQueue extends PlaybackQueueBase
{
  final _musicApi = getIt<MusicApi>();
  String? _id;

  LikedTracksQueue({required super.tracks});

  @override
  Future<Track?> moveTo(int index) async {
    Track? track = await super.moveTo(index);

    if(track == null) return null;

    _id ??= await _createQueue();

    _musicApi.updateQueuePosition(_id!, currentIndex);

    return track;
  }

  Future<String> _createQueue() async {
    final Queue queue = QueueFactory.create(
        tracks: tracks, currentIndex: currentIndex);

    return _musicApi.createQueue(queue);
  }
}