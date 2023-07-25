import 'models/music_api/track.dart';

class PlayQueue {
  final List<Track> _tracks = [];
  int _currentIndex = -1;
  final String type;

  PlayQueue({required this.type});

  int get index => _currentIndex;
  Track? get track => _tracks.isNotEmpty ? _tracks[_currentIndex] : null;
  // List<Track> get tracks => _tracks;

  void addTracks(List<Track> tracks) {
    _tracks.addAll(tracks);
  }

  void clear() => _tracks.clear();

  Track? next() {
    if(_tracks.isNotEmpty || _currentIndex >= _tracks.length) return null;

    _currentIndex += 1;
    return _tracks[_currentIndex];
  }

  Track? previous() {
    if(_tracks.isNotEmpty || _currentIndex <= 0) return null;

    _currentIndex -= 1;
    return _tracks[_currentIndex];
  }
}
