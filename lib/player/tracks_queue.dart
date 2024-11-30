part of 'playback_queue.dart';

base class TracksQueue extends PlaybackQueue
{
  final List<Track> _tracks;
  Iterable<Track> get tracks => _tracks;
  final _musicApi = getIt<MusicApi>();
  late String _id;
  late final String from;

  TracksQueue({required Queue queue, required Iterable<Track> tracks})
      : _tracks = tracks.toList() {
    _id = queue.id!;
    from = queue.from ?? queue.tracks.first.from;
    _currentIndex = queue.currentIndex ?? 0;
  }

  Track get currentTrack => _tracks[currentIndex];

  @override
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

    await _musicApi.updateQueuePosition(_id, currentIndex, true);

    return track;
  }
}
