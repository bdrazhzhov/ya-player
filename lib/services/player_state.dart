import 'package:audio_player_gst/events.dart';
import 'package:flutter/foundation.dart';
import 'package:ya_player/services/preferences.dart';
import 'package:ya_player/services/state_enums.dart';

import '../player/playback_queue.dart';
import 'audio_player.dart';
import '/dbus/mpris/mpris_player.dart';
import '/dbus/sleep_inhibitor.dart';
import 'service_locator.dart';

enum PlayBackState { playing, paused, stopped }

class PlayerState {
  final _audioPlayer = getIt<AudioPlayer>();
  final _prefs = getIt<Preferences>();
  final _sleepInhibitor = getIt<SleepInhibitor>();
  final _mpris = getIt<OrgMprisMediaPlayer2>();
  final _queue = getIt<PlaybackQueue>();

  final canPlayNotifier = ValueNotifier<bool>(false);
  final canPauseNotifier = ValueNotifier<bool>(false);
  final canNextNotifier = ValueNotifier<bool>(false);
  final canPrevNotifier = ValueNotifier<bool>(false);
  final canShuffleNotifier = ValueNotifier<bool>(false);
  final canRepeatNotifier = ValueNotifier<bool>(false);
  final canSeekNotifier = ValueNotifier<bool>(false);
  final playBackStateNotifier = ValueNotifier<PlayBackState>(PlayBackState.stopped);
  final repeatModeNotifier = ValueNotifier<RepeatMode>(RepeatMode.off);
  final rateNotifier = ValueNotifier<double>(1.0);
  final shuffleNotifier = ValueNotifier<bool>(false);
  final repeatNotifier = ValueNotifier<RepeatMode>(RepeatMode.off);

  PlayerState() {
    _listenToPlayerAbilities();
    _listenToPlaybackState();
    _listenToShuffleState();
    _listenToRepeatState();
    _listenToRate();
    _listenToVolume();
    _listenToPlayingState();

    canRepeatNotifier.value = true;
    _mpris.canShuffle = true;
    shuffleNotifier.value = _prefs.shuffle;
    _mpris.canRepeat = true;
    repeatNotifier.value = _prefs.repeat;
    _audioPlayer.volumeNotifier.value = _prefs.volume.clamp(0, 1);
  }

  void _listenToPlayerAbilities() {
    canNextNotifier.addListener((){
      _mpris.canGoNext = canNextNotifier.value;
    });

    canPrevNotifier.addListener((){
      _mpris.canGoPrevious = canNextNotifier.value;
    });

    canPlayNotifier.addListener((){
      _mpris.canPlay = canPlayNotifier.value;
    });

    canPauseNotifier.addListener((){
      _mpris.canPause = canPauseNotifier.value;
    });

    canSeekNotifier.addListener((){
      _mpris.canSeek = canSeekNotifier.value;
    });

    canShuffleNotifier.addListener((){
      _mpris.canShuffle = canShuffleNotifier.value;
    });

    canRepeatNotifier.addListener((){
      _mpris.canRepeat = canRepeatNotifier.value;
    });
  }

  void _listenToPlaybackState() {
    playBackStateNotifier.addListener((){
      switch(playBackStateNotifier.value) {
        case PlayBackState.playing:
          canPauseNotifier.value = true;
          canPlayNotifier.value = false;
          canSeekNotifier.value = true;
          _mpris.playbackState = 'Playing';
          _sleepInhibitor.blockSleep();
          break;
        case PlayBackState.paused:
          canPauseNotifier.value = false;
          canPlayNotifier.value = true;
          canSeekNotifier.value = true;
          _mpris.playbackState = 'Paused';
          _sleepInhibitor.unblockSleep();
          break;
        case PlayBackState.stopped:
          canPauseNotifier.value = false;
          canPlayNotifier.value = true;
          canSeekNotifier.value = false;
          _mpris.playbackState = 'Stopped';
          _sleepInhibitor.unblockSleep();
          break;
      }
    });
  }

  void _listenToShuffleState() {
    _mpris.shuffleStream.listen((bool value){
      shuffleNotifier.value = value;
    });

    shuffleNotifier.addListener((){
      _prefs.setShuffle(shuffleNotifier.value);
      _mpris.shuffle = shuffleNotifier.value;
      _queue.isShuffleEnabled = shuffleNotifier.value;
    });
  }

  void _listenToRepeatState() {
    _mpris.repeatStream.listen((RepeatMode value){
      repeatModeNotifier.value = value;
    });

    repeatModeNotifier.addListener((){
      _prefs.setRepeat(repeatModeNotifier.value);
      _mpris.repeat = repeatModeNotifier.value;
      _queue.repeatMode = repeatModeNotifier.value;
    });
  }

  void _listenToRate() {
    _mpris.rateStream.listen((double value){
      rateNotifier.value = value;
    });

    rateNotifier.addListener((){
      _mpris.rate = rateNotifier.value;
    });
  }

  void _listenToVolume() {
    _audioPlayer.volumeNotifier.addListener((){
      _prefs.setVolume(_audioPlayer.volumeNotifier.value);
      _audioPlayer.setVolume(_audioPlayer.volumeNotifier.value);
      _mpris.volume = _audioPlayer.volumeNotifier.value;
    });

    _mpris.volumeStream.listen((volume){
      _audioPlayer.volumeNotifier.value = volume;
    });
  }

  void _listenToPlayingState() {
    _audioPlayer.playingStateNotifier.addListener((){
      switch(_audioPlayer.playingStateNotifier.value) {
        case PlayingState.pending:
          playBackStateNotifier.value = PlayBackState.stopped;
        case PlayingState.idle:
          playBackStateNotifier.value = PlayBackState.stopped;
        case PlayingState.ready:
          playBackStateNotifier.value = PlayBackState.stopped;
        case PlayingState.playing:
          playBackStateNotifier.value = PlayBackState.playing;
        case PlayingState.paused:
          playBackStateNotifier.value = PlayBackState.paused;
        case PlayingState.completed:
          playBackStateNotifier.value = PlayBackState.stopped;
        case PlayingState.unknown:
          playBackStateNotifier.value = PlayBackState.stopped;
      }
    });
  }
}
