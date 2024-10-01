import '../../models/music_api/track.dart';

class PlaybackQueueBase
{
  final List<Track> _tracks;
  int _currentIndex = -1;

  int get currentIndex => _currentIndex;
  List<Track> get tracks => _tracks;

  PlaybackQueueBase({
    required List<Track> tracks,
  }) : _tracks = tracks;

  void addAll(List<Track> tracks) {
    _tracks.addAll(tracks);
  }

  void add(Track track) {
    _tracks.add(track);
  }

  // void clear() {
  //   _currentIndex = -1;
  //   _tracks.clear();
  // }

  Future<Track?> next() async {
    if(_tracks.isEmpty || _currentIndex >= _tracks.length - 1) return null;

    _currentIndex += 1;

    return _tracks[_currentIndex];
  }

  Track? previous() {
    if(_tracks.isEmpty || _currentIndex == 0) return null;

    _currentIndex -= 1;

    return _tracks[_currentIndex];
  }

  Future<Track?> moveTo(int index) async {
    if(_tracks.isNotEmpty && index >= 0 && index < _tracks.length) {
      _currentIndex = index;
      return _tracks[index];
    }

    return null;
  }
}