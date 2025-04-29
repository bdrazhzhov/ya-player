import 'dart:math';

import '/models/ynison/player_state.dart';
import '/services/state_enums.dart';
import '/helpers/event.dart';
import '/models/music_api/track.dart';

final class PlaybackQueue {
  final List<Track> _tracks = [];
  int _currentIndex = -1;
  final _trackListChangedEvent = Event<Iterable<Track>>();

  int get currentIndex => _currentIndex;

  Track? get currentTrack => _tracks[_currentIndex];

  bool get canGoNext => _tracks.isNotEmpty && _currentIndex < (_tracks.length - 1);

  bool get canGoPrevious => _tracks.isNotEmpty && _currentIndex > 0;

  Iterable<Track> get tracks => _tracks;

  EventProxy<Iterable<Track>> get trackListChanged => EventProxy(_trackListChangedEvent);

  var repeatMode = RepeatMode.off;
  bool isShuffleEnabled = false;

  void clear() {
    _tracks.clear();
    _currentIndex = -1;
    repeatMode = RepeatMode.off;
    isShuffleEnabled = false;
  }

  void replaceTracks(Iterable<Track> tracks) {
    clear();
    _tracks.addAll(tracks);
    _currentIndex = tracks.isNotEmpty ? 0 : -1;
    _trackListChangedEvent.emit(_tracks);
  }

  void replaceTracksLeft(Iterable<Track> tracks) {
    _tracks.removeRange(_currentIndex + 1, _tracks.length);
    _tracks.addAll(tracks);
    _trackListChangedEvent.emit(_tracks);
  }

  void next() {
    if (!canGoNext) return;

    if(isShuffleEnabled) {
      _currentIndex = Random().nextInt(_tracks.length);
    }
    else {
      switch(repeatMode) {
        case RepeatMode.on:
          if(_currentIndex == (_tracks.length - 1)) {
            _currentIndex = 0;
          }
        case RepeatMode.one:
          break;
        case RepeatMode.off:
          _currentIndex += 1;
      }
    }
  }

  void previous() {
    if (!canGoPrevious) return;

    if(isShuffleEnabled) {
      _currentIndex = Random().nextInt(_tracks.length);
    }
    else {
      switch(repeatMode) {
        case RepeatMode.on:
          if(_currentIndex == 0) {
            _currentIndex = _tracks.length - 1;
          }
        case RepeatMode.one:
          break;
        case RepeatMode.off:
          _currentIndex -= 1;
      }
    }
  }

  void moveTo(int index) {
    if (_tracks.isNotEmpty && index >= 0 && index < _tracks.length) {
      _currentIndex = index;
    }
  }

  int indexOf(Track track) => _tracks.indexOf(track);

  Iterable<Playable> toPlayableList(String from) {
    return _tracks.map((track) => Playable(
        from: from,
        playableType: 'TRACK',
        albumId: track.firstAlbumId.toString(),
        title: track.title,
        playableId: track.id,
        coverUrl: track.coverUri
      ));
  }
}
