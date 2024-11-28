import 'dart:async';
import 'dart:math';

import 'package:audio_player_gst/audio_player_gst.dart';
import 'package:audio_player_gst/events.dart';

import 'mpris/mpris_player.dart';
import 'services/service_locator.dart';

final class AudioPlayer {
  final _platformPlayer = AudioPlayerGst();
  final _mpris = getIt<OrgMprisMediaPlayer2>();
  var _duration = const Duration(milliseconds: 0);
  var _position = const Duration(milliseconds: 0);
  var _buffered = const Duration(milliseconds: 0);
  var _playingState = PlayingState.unknown;
  bool _isPlaying = false;

  final _eventController = StreamController<PlaybackEventMessage>.broadcast();
  Stream<PlaybackEventMessage> get playbackEventMessageStream => _eventController.stream;

  AudioPlayer() {
    _listenToEventsStream();
    _mpris.positionStream.listen(seek);
    _mpris.volumeStream.listen(setVolume);
    _listenToControlStream();
  }

  void _listenToEventsStream() {
    AudioPlayerGst.eventsStream().listen((EventBase event) {
      switch(event) {
        case DurationEvent durationEvent:
          _duration = durationEvent.duration;
          _broadcastPlaybackEvent();
        case PlayingStateEvent playingStateEvent:
          _playingState = playingStateEvent.state;
          _broadcastPlaybackEvent();
          _updateMprisPlayingState(_playingState);
        case PositionEvent positionEvent:
          _position = positionEvent.position;
          _broadcastPlaybackEvent();
          _mpris.position = _position;
        case BufferingEvent bufferingEvent:
          if(_duration.inMilliseconds == 0) break;
          _buffered = Duration(microseconds: (_duration.inMicroseconds * bufferingEvent.percent).round());
          _broadcastPlaybackEvent();
        case VolumeEvent volumeEvent:
          _linearVolume = sqrt(volumeEvent.value).toDouble();
          _broadcastPlaybackEvent();
        case UnknownEvent():
          // TODO: Handle this case.
      }
    });
  }
  void _broadcastPlaybackEvent() {
    _eventController.add(PlaybackEventMessage(
      position: _position,
      bufferedPosition: _buffered,
      duration: _duration,
      playingState: _playingState,
      volume: _linearVolume
    ));

    if(_playingState == PlayingState.completed) {
      _playingState = PlayingState.idle;
    }
  }

  Future<void> play() => _platformPlayer.play();
  Future<void> pause() => _platformPlayer.pause();
  Future<void> stop() async {
    await _platformPlayer.pause();
    _position = Duration.zero;
    _playingState = PlayingState.idle;
    _broadcastPlaybackEvent();
  }
  Future<void> seek(Duration position) => _platformPlayer.seek(position);

  Future<void> setUrl(String url) => _platformPlayer.setUrl(url);

  double _linearVolume = 1;
  double get volume => _linearVolume;

  Future<void> setVolume(double value){
    _linearVolume = value;
    value = pow(value, 2).toDouble();

    return _platformPlayer.setVolume(value);
  }

  void _listenToControlStream() {
    _mpris.controlStream.listen((event) {
      switch (event) {
        case 'play':
          play();
        case 'pause':
          pause();
        case 'playPause':
          _isPlaying ? play() : pause();
      }
    });
  }

  void _updateMprisPlayingState(PlayingState playingState) {
    if(playingState == PlayingState.paused) {
      _isPlaying = false;
      _mpris.playbackState = 'Paused';
    } else if(playingState == PlayingState.playing) {
      _isPlaying = true;
      _mpris.playbackState = 'Playing';
    } else if(playingState == PlayingState.completed) {
      _isPlaying = false;
      _mpris.playbackState = 'Stopped';
    }
  }
}

class PlaybackEventMessage {
  final Duration position;
  final Duration bufferedPosition;
  final Duration? duration;
  final PlayingState playingState;
  final double volume;

  PlaybackEventMessage({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
    required this.playingState,
    required this.volume
  });

  @override
  String toString() {
    return 'position: $position, bufferedPosition: $bufferedPosition'
        'duration: $duration, playingState: $playingState, volume: $volume';
  }
}
