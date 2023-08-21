import 'dart:async';

import '../models/music_api/track.dart';

class QueueNames {
  static const String trackList = 'desktop_win-own_tracks-track-default';
  static const String album = 'desktop_win-album-album-default';
  static const String playlist = 'desktop_win-own_playlists-playlist-default';
  static const String artist = 'desktop_win-artist-track-default';
}

class PlaybackQueue {
  final List<Track> _tracks;
  int _currentIndex = -1;
  final String id;
  final String name;
  final _preloadStreamController = StreamController<List<int>>();

  Stream<List<int>> get preloadStream => _preloadStreamController.stream;
  int get currentIndex => _currentIndex;
  List<Track> get tracks => _tracks;

  PlaybackQueue({
    required tracks,
    required this.id,
    required this.name
  }) : _tracks = tracks;

  void addAll(List<Track> tracks) {
    _tracks.addAll(tracks);
  }

  void add(Track track) {
    _tracks.add(track);
  }

  void clear() {
    _currentIndex = -1;
    _tracks.clear();
  }

  Track? next() {
    if(_tracks.isEmpty || _currentIndex >= _tracks.length - 1) return null;

    _currentIndex += 1;

    if(_tracks.length - _currentIndex <= 3) {
      _preloadStreamController.add(lastTrackIds());
    }

    return _tracks[_currentIndex];
  }

  Track? previous() {
    if(_tracks.isEmpty || _currentIndex == 0) return null;

    _currentIndex -= 1;

    return _tracks[_currentIndex];
  }

  Track? moveTo(int index) {
    if(_tracks.isNotEmpty && index >= 0 && index < _tracks.length) {
      _currentIndex = index;
      return _tracks[index];
    }

    return null;
  }

  List<int> lastTrackIds() => _tracks.reversed.take(3).map((track) => track.id).toList();
}