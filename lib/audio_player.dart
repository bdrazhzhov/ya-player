import 'dart:async';
import 'dart:math';

import 'package:audio_player_gst/audio_player_gst.dart';
import 'package:audio_player_gst/events.dart';
import 'package:flutter/foundation.dart';

import 'notifiers/track_duration_notifier.dart';

final class AudioPlayer {
  final _platformPlayer = AudioPlayerGst();
  var _duration = const Duration(milliseconds: 0);
  var _position = const Duration(milliseconds: 0);
  var _buffered = const Duration(milliseconds: 0);

  final trackDurationNotifier = TrackDurationNotifier();
  late final volumeNotifier = ValueNotifier<double>(_linearVolume);
  late final playingStateNotifier = ValueNotifier<PlayingState>(PlayingState.unknown);

  AudioPlayer() {
    _listenToEventsStream();
  }

  void _listenToEventsStream() {
    _platformPlayer.eventsStream().listen((EventBase event) {
      switch(event) {
        case DurationEvent durationEvent:
          _duration = durationEvent.duration;
          _notifyPositionUpdate();
        case PlayingStateEvent playingStateEvent:
          playingStateNotifier.value = playingStateEvent.state;
        case PositionEvent positionEvent:
          _position = positionEvent.position;
          _notifyPositionUpdate();
        case BufferingEvent bufferingEvent:
          if(_duration.inMilliseconds == 0) break;
          _buffered = Duration(microseconds: (_duration.inMicroseconds * bufferingEvent.percent).round());
          _notifyPositionUpdate();
        case VolumeEvent volumeEvent:
          _linearVolume = pow(volumeEvent.value, 1.0/3).toDouble();
          volumeNotifier.value = _linearVolume;
        case UnknownEvent():
          // TODO: Handle this case.
      }
    });
  }

  void _notifyPositionUpdate() {
    trackDurationNotifier.value = TrackDurationState(
      position: _position,
      buffered: _buffered,
      duration: _duration
    );
  }

  Future<void> play() => _platformPlayer.play();
  Future<void> pause() => _platformPlayer.pause();
  Future<void> stop() async {
    await _platformPlayer.pause();
    _position = Duration.zero;
    playingStateNotifier.value = PlayingState.idle;
  }
  Future<void> seek(Duration position) => _platformPlayer.seek(position);

  Future<void> setUrl(String url) => _platformPlayer.setUrl(url);

  double _linearVolume = 1;
  double get volume => _linearVolume;

  Future<void> setVolume(double value){
    _linearVolume = value;
    value = pow(value, 3).toDouble();

    return _platformPlayer.setVolume(value);
  }

  Future<void> setRate(double rate) async => _platformPlayer.setRate(rate);
}
