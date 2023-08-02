import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

Future<MyAudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.drazhzhov.ya_player.audio',
      androidNotificationChannelName: 'YaPlayer',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

enum TrackSkipType { previous, next }

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  List<MediaControl> _mediaControls = [
    MediaControl.skipToPrevious,
    MediaControl.play,
    MediaControl.stop,
    MediaControl.skipToNext
  ];

  final _skipController = StreamController<TrackSkipType>();
  Stream<TrackSkipType> get skipStream => _skipController.stream;

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToPlayingStream();
    _player.playerStateStream.listen((state) {
      debugPrint('PlayerStateStream: $state');
    });
  }

  void _listenToPlayingStream() {
    _player.playingStream.listen((playing) {
      debugPrint('PlayingStream: $playing');
      _isPlaying = playing;
      _mediaControls = [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ];
      playbackState.add(playbackState.value.copyWith(
        playing: _isPlaying,
        controls: _mediaControls,
      ));
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      // debugPrint('Playback event: $event');
      playbackState.add(playbackState.value.copyWith(
        controls: _mediaControls,
        systemActions: const { MediaAction.seek },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _isPlaying,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  Future<void> playTrack(MediaItem track) async {
    debugPrint('Playing URL: ${track.extras!['url']}');
    await _player.setUrl(track.extras!['url']);
    // looks like some kind of bug:
    // playing doesn't start without this line
    await setVolume(volume);
    mediaItem.add(track);
    return _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    _skipController.add(TrackSkipType.next);
  }

  @override
  Future<void> skipToPrevious() async {
    _skipController.add(TrackSkipType.previous);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch(name) {
      case 'dbusVolume':
        if(extras == null || extras['value'] == null) break;

        final value = extras['value'] as double;
        await setVolume(value);
      case 'dispose':
        await _player.dispose();
        super.stop();
      default:
        debugPrint('Unknown custom action: $name wit extras: $extras');
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  double _linearVolume = 1;

  double get volume => _linearVolume;

  Future<void> setVolume(double value){
    _linearVolume = value;

    if(!kIsWeb) {
      if(Platform.isWindows) {
        value = pow(value, 3).toDouble();
      }
      else if(Platform.isLinux) {
        value = pow(value, 2).toDouble();
      }
    }

    return _player.setVolume(value);
  }
}
