part of 'playback_queue.dart';

final class StationQueue extends PlaybackQueue
{
  final List<Track> _tracks = [];
  final _musicApi = getIt<MusicApi>();
  late Queue _queue;
  int _realIndex = -1; // необходим для правильной работы очереди
                       // в случаях, когда пропускаются треки
  Iterable<int> _lastTracksIds = [];

  final Station station;
  StationQueue({ required this.station, (Queue, Iterable<Track>)? initialData }) {
    if(initialData != null) {
      _queue = initialData.$1;
      _tracks.addAll(initialData.$2);
    }
  }

  @override
  Future<Track?> next() async {
    if(_tracks.length - _realIndex <= 3) {
      _lastTracksIds = _tracks.skip(_tracks.length - 2).map((t) => t.id);
      await loadTracks();
    }
    else if(_tracks.isNotEmpty && _realIndex == _tracks.length - 1) {
      _lastTracksIds = [];
      await loadTracks();
    }

    Track? track;
    if(_tracks.isEmpty || _realIndex >= _tracks.length - 1) {
      track = null;
    }
    else {
      _currentIndex += 1;
      _realIndex += 1;

      track = _tracks[_realIndex];
    }

    return track;
  }

  Future<Track> skip() async {
    _currentIndex += 1;
    _realIndex += 1;

    Track track = _tracks[_realIndex];
    _lastTracksIds = _tracks.skip(_realIndex).map((t) => t.id).toList();
    _tracks.removeRange(_realIndex, _tracks.length);
    _realIndex -= 1;

    return track;
  }

  Future<void> updatePosition({bool isInteractive = false}) async {
    try {
      await _musicApi.updateQueuePosition(_queue.id!, _currentIndex, isInteractive);
    } on QueueIndexInvalid {
      _queue = await QueueFactory.create(tracksSource: (station, _tracks));
    }
  }

  Future<void> loadTracks() async {
    final Iterable<Track> tracks = await _musicApi.stationTacks(station.id, _lastTracksIds);
    _tracks.addAll(tracks);

    debugPrint('Tracks in queue:\n${_tracks.map((e) => '${e.id} - ${e.title}').join('\n')}');
  }
  
  Future<void> reloadLastTracks() async {
    int startIndex = _realIndex;
    if(startIndex == -1) startIndex = 0;

    _lastTracksIds = _tracks.skip(startIndex).map((t) => t.id).toList();
    _tracks.removeRange(startIndex + 1, _tracks.length);
    await loadTracks();
  }
}
