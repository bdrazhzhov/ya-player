import 'dart:async';

import 'package:audio_player_gst/events.dart';

import '/helpers/event.dart';
import '/services/logger.dart';
import '/models/music_api/track.dart';
import '/services/audio_player.dart';
import '/services/music_api.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'playback_queue.dart';

class Player {
  final _playerState = getIt<PlayerState>();
  final _audioPlayer = getIt<AudioPlayer>();
  final _musicApi = getIt<MusicApi>();
  final _queue = getIt<PlaybackQueue>();
  bool isNewTrack = true;

  final _trackLoadedEvent = Event<Track>();
  final _beforeNewTrackStartedEvent = Event<Track>();
  final _playingStartedEvent = Event<Track>();
  final _trackFinishedEvent = Event<Track>();
  final _beforeNextTrackEvent = Event<Track>();

  EventProxy<Track> get trackLoadedEvent => EventProxy(_trackLoadedEvent);
  EventProxy<Track> get beforeNewTrackStartedEvent => EventProxy(_beforeNewTrackStartedEvent);
  EventProxy<Track> get playingStartedEvent => EventProxy(_playingStartedEvent);
  EventProxy<Track> get trackFinishedEvent => EventProxy(_trackFinishedEvent);
  EventProxy<Track> get beforeNextTrackEvent => EventProxy(_beforeNextTrackEvent);

  Player() {
    _audioPlayer.playingStateNotifier.addListener(() async {
      if(_audioPlayer.playingStateNotifier.value != PlayingState.completed) return;

      await _trackFinishedEvent.emit(_queue.currentTrack!);
      await next();
    });
  }

  Future<void> play() async {
    if(!_playerState.canPlayNotifier.value) return;

    if(isNewTrack) {
      isNewTrack = false;
      await _beforeNewTrackStartedEvent.emit(_queue.currentTrack!);
    }
    
    await _audioPlayer.play();
    await _playingStartedEvent.emit(_queue.currentTrack!);
  }

  Future<void> pause() async {
    if(!_playerState.canPauseNotifier.value) return;

    await _audioPlayer.pause();
  }

  Future<void> playPause() async {
    if(_audioPlayer.playingStateNotifier.value == PlayingState.playing) {
      await pause();
    }
    else {
      await play();
    }
  }

  Future<void> _beginPlaying() async {
    _playerState.canNextNotifier.value = _queue.canGoNext;
    _playerState.canPrevNotifier.value = _queue.canGoPrevious;
    await loadTrack(_queue.currentTrack!);
    await play();
  }

  Future<void> next() async {
    if(!_queue.canGoNext) return;

    _beforeNextTrackEvent.emit(_queue.currentTrack!);
    _queue.next();
    await _beginPlaying();
  }

  Future<void> previous() async {
    if(!_queue.canGoPrevious) return;

    _queue.previous();
    await _beginPlaying();
  }

  Future<void> loadTrack(Track track) async {
    _playerState.canPlayNotifier.value = true;
    _playerState.canNextNotifier.value = _queue.canGoNext;
    _playerState.canPrevNotifier.value = _queue.canGoPrevious;
    final UrlData urlData = await _musicApi.trackDownloadUrl(track.id);
    await _audioPlayer.setUrl(urlData.url, urlData.encryptionKey);
    isNewTrack = true;
    _trackLoadedEvent.emit(track);
  }

  Future<void> playPauseTrack(Track track) async {
    if(track == _queue.currentTrack) {
      await playPause();
      return;
    }

    int index = _queue.indexOf(track);
    if(index == -1) return;

    _queue.moveTo(index);
    await _beginPlaying();
  }

  Future<void> playPauseByIndex(int index) async {
    if(index == _queue.currentIndex) {
      await playPause();
      return;
    }

    _queue.moveTo(index);
    if(index != _queue.currentIndex) {
      logger.w('Error: index is not equal to current index');
      return;
    }

    await _beginPlaying();
  }
}
