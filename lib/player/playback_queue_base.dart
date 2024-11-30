import '/player/queue_factory.dart';
import '/models/music_api/queue.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import '/models/music_api/track.dart';
import 'tracks_source.dart';

base class PlaybackQueueBase
{
  final TracksSource tracksSource;
  final List<Track> _tracks;
  Iterable<Track> get tracks => _tracks;

  final _musicApi = getIt<MusicApi>();

  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  String? _id;
  String? get id => _id;

  late final String from;
  
  PlaybackQueueBase(this.tracksSource) :
        from = tracksSourceStrings[tracksSource.sourceType],
        _tracks = tracksSource.getTracks().toList();

  Future<Track?> next() async {
    if(_tracks.isEmpty || _currentIndex >= _tracks.length - 1) return null;

    _currentIndex += 1;

    return _tracks[_currentIndex];
  }

  Future<Track?> previous() async {
    if(_tracks.isEmpty || _currentIndex == 0) return null;

    _currentIndex -= 1;

    return _tracks[_currentIndex];
  }

  Future<Track?> moveTo(int index) async {
    Track? track;

    if(_tracks.isNotEmpty && index >= 0 && index < _tracks.length) {
      _currentIndex = index;
      track = _tracks[index];
    }

    if(track == null) return null;

    if(id == null) {
      final Queue queue = await QueueFactory.create(
          tracksSource: tracksSource.source!, currentIndex: currentIndex);
      _id = queue.id;
    }
    else {
      _musicApi.updateQueuePosition(id!, currentIndex, true);
    }

    return track;
  }
}
