import 'dart:async';
import 'dart:math';

import 'package:audio_player_gst/events.dart';
import 'package:ya_player/state_enums.dart';

import '/notifiers/play_button_notifier.dart';
import '/audio_player.dart';
import '/app_state.dart';
import '/models/music_api/track.dart';
import '/models/play_info.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import 'playback_queue.dart';

part 'station_player.dart';
part 'tracks_player.dart';

abstract base class PlayerBase {
  final _musicApi = getIt<MusicApi>();
  final _appState = getIt<AppState>();
  final _audioPlayer = getIt<AudioPlayer>();
  PlayInfo? _currentPlayInfo;

  PlayerBase() {
    _audioPlayer.playingStateNotifier.addListener(_onPlayingStateChange);
  }

  void cleanUp() {
    _audioPlayer.playingStateNotifier.removeListener(_onPlayingStateChange);
  }

  void next();

  void previous() {}

  Future<void> playByIndex(int? index) async {}

  Future<void> _playTrack(Track track, String from) async {
    if(_currentPlayInfo != null) {
      _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.position;
      await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    }

    _appState.trackNotifier.value = track;
    _currentPlayInfo = PlayInfo(track, from);
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());

    return _addTrackToPlayer(track);
  }

  Future<void> _addTrackToPlayer(Track track) async {
    final UrlData urlData = await _musicApi.trackDownloadUrl(track.id);
    await _audioPlayer.setUrl(urlData.url, urlData.encryptionKey);
    await _audioPlayer.play();
  }

  Future<void> pause() => _audioPlayer.pause();

  void _onPlayingStateChange() {
    if(_audioPlayer.playingStateNotifier.value != PlayingState.completed) return;

    next();
  }
}
