import 'dart:async';
import 'dart:math';

import 'package:audio_player_gst/events.dart';
import 'package:ya_player/state_enums.dart';

import '/notifiers/play_button_notifier.dart';
import '/dbus/mpris/metadata.dart';
import '/dbus/mpris/mpris_player.dart';
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
  final _mpris = getIt<OrgMprisMediaPlayer2>();
  late StreamSubscription<PlaybackEventMessage> _nextTrackSubscription;
  late StreamSubscription<String> _controlSubscription;

  PlayerBase() {
    _listenToControlStream();
    _listenToPlaybackState();
  }

  void cleanUp() {
    _nextTrackSubscription.cancel();
    _controlSubscription.cancel();
  }

  void next();

  void previous() {}

  Future<void> playByIndex(int? index) async {}

  Future<void> _playTrack(Track track, String from) async {
    if(_currentPlayInfo != null) {
      _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.current;
      await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    }

    await _addTrackToPlayer(track);

    _appState.trackNotifier.value = track;
    _currentPlayInfo = PlayInfo(track, from);
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
  }

  Future<void> _addTrackToPlayer(Track track) async {
    String? url = await _musicApi.trackDownloadUrl(track.id);

    if(url == null) return;
    await _audioPlayer.setUrl(url);

    List<String> artist = track.artists.map((artist) => artist.name).toList();

    String? artUrl;
    if(track.coverUri != null) {
      artUrl = MusicApi.imageUrl(track.coverUri!, '260x260');
    }

    _mpris.metadata = Metadata(
        title: track.title,
        length: track.duration,
        artist: artist,
        artUrl: artUrl,
        album: track.albums.first.title,
        genre: null
    );

    await _audioPlayer.play();
  }

  Future<void> pause() => _audioPlayer.pause();

  void _listenToControlStream() {
    _controlSubscription = _mpris.controlStream.listen((event) {
      switch (event) {
        case 'next':
          next();
        case 'previous':
          previous();
      }
    });
  }

  void _listenToPlaybackState() {
    _nextTrackSubscription = _audioPlayer.playbackEventMessageStream.listen((PlaybackEventMessage msg){
      if(msg.playingState == PlayingState.completed) {
        next();
      }
    });
  }
}
