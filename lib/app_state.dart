import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:ya_player/services/preferences.dart';

import 'models/music_api/account.dart';
import 'models/music_api/station.dart';
import 'models/music_api/track.dart';
import 'models/play_info.dart';
import 'music_api.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'services/audio_handler.dart';
import 'services/service_locator.dart';
import 'utils/ym_login.dart';

class AppState {
  // Listeners: Updates going to the UI
  final progressNotifier = ProgressNotifier();
  final playButtonNotifier = PlayButtonNotifier();
  final trackNotifier = ValueNotifier<Track?>(null);
  final trackLikeNotifier = ValueNotifier<bool>(false);
  final currentStationNotifier = ValueNotifier<Station?>(null);
  final stationsNotifier = ValueNotifier<List<Station>>([]);
  final accountNotifier = ValueNotifier<Account?>(null);
  final List<Track> playlist = [];

  final _audioHandler = getIt<MyAudioHandler>();
  final _musicApi = getIt<MusicApi>();
  int _currentIndex = -1;
  PlayInfo? _currentPlayInfo;
  final _prefs = getIt<Preferences>();
  late final List<int> _likedTracks;

  // Events: Calls coming from the UI
  void init() async {
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToSkipEvents();

    await requestAccountData();
    requestStations();

    _audioHandler.volume = _prefs.volume;
    _requestLikedTracks();
  }

  Future<void> _requestLikedTracks() async {
    if((_prefs.authToken?.length ?? 0) == 0) return;

    _likedTracks = await _musicApi.likedTracks();
    _likedTracks.sort();
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        // _audioHandler.seek(Duration.zero);
        // _audioHandler.pause();
        next();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToSkipEvents() {
    _audioHandler.skipStream.listen((TrackSkipType event) {
      switch(event) {
        case TrackSkipType.next: next();
        case TrackSkipType.previous: previous();
      }
    });
  }

  double get volume => _audioHandler.volume;
  set volume(double value) {
    _audioHandler.volume = value;
    _prefs.setVolume(value);
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();
  void stop() => _audioHandler.stop();
  void seek(Duration position) => _audioHandler.seek(position);

  Future<void> previous() async {
    if(playlist.isEmpty || _currentIndex == 0) return;
    _currentIndex -= 1;
    final track = playlist[_currentIndex];
    // playTrack(track);
    await _playStationTrack(currentStationNotifier.value!, track);
  }

  List<int> _getLastTrackIds() {
    return playlist.isNotEmpty ? playlist.reversed.take(3).map((e) => e.id).toList() : [];
  }

  Future<void> next() async {
    if(playlist.isEmpty || _currentIndex == playlist.length - 1) return;

    _currentIndex += 1;
    final track = playlist[_currentIndex];
    await _playStationTrack(currentStationNotifier.value!, track);

    // When playlist almost reached its end loading new tracks
    // and adding to the end of playlist
    if(playlist.length - _currentIndex <= 3) {
      final lastTrackIds = _getLastTrackIds();
      final List<Track> tracks = await _musicApi.stationTacks(currentStationNotifier.value!.id, lastTrackIds);
      playlist.addAll(tracks);
      debugPrint('Added tracks: ${tracks.map((e) => e.title)}');
    }
  }

  Future<void> selectStation(Station station) async {
    currentStationNotifier.value = station;
    final lastTrackIds = _getLastTrackIds();
    final List<Track> tracks = await _musicApi.stationTacks(station.id, lastTrackIds);
    playlist.clear();
    _currentIndex = 0;
    playlist.addAll(tracks);
    await _playStationTrack(station, playlist.first);
  }

  Future<void> _playTrack(Track track) async {
    String? url = await _musicApi.trackDownloadUrl(track.id);

    if(url == null) return;

    final mediaItem = MediaItem(
      id: track.id.toString(),
      title: track.title,
      artist: track.artists.first.name,
      album: track.albums.first.title,
      duration: track.duration,
      artUri: MusicApi.trackImageUrl(track, '150x150'),
      extras: {
        'url': url
      }
    );
    _audioHandler.playTrack(mediaItem);
    trackNotifier.value = track;
    trackLikeNotifier.value = binarySearch(_likedTracks, track.id) != -1;
  }

  Future<void> _playStationTrack(Station station, Track track) async {
    if(_currentPlayInfo != null) {
      _currentPlayInfo!.totalPlayed = progressNotifier.value.current;
      final bool isSkipped = progressNotifier.value.current.inMilliseconds / track.duration.inMilliseconds < 0.9;
      _sendTrackStatistics(_currentPlayInfo!, isSkipped ? 'skip' : 'trackFinished');
    }

    await _playTrack(track);
    _currentPlayInfo = PlayInfo(track, station.id);
    _sendTrackStatistics(_currentPlayInfo!, 'trackStarted');
  }

  Future<void> _sendTrackStatistics(PlayInfo playInfo, String feedback) async {
    await _musicApi.sendStationTrackFeedback(playInfo.stationId,
        playInfo.track, feedback, playInfo.totalPlayed);
    await _musicApi.sendPlayingStatistics(playInfo.toYmPlayAudio());
  }

  Future<void> likeCurrentTrack() async {
    if(_currentPlayInfo == null) return;

    final Track track = _currentPlayInfo!.track;

    if(track.liked) {
      await _musicApi.unlikeTrack(track);
      _likedTracks.add(track.id);
    }
    else {
      await _musicApi.likeTrack(track);
      _likedTracks.removeWhere((trackId) => trackId == track.id);
    }

    _likedTracks.sort();

    trackLikeNotifier.value = track.liked;
  }

  void _reset() {
    stop();
    playlist.clear();
    _currentIndex = -1;
    _currentPlayInfo = null;
    playButtonNotifier.value = ButtonState.paused;
    trackNotifier.value = null;
    currentStationNotifier.value = null;
    stationsNotifier.value = [];
    accountNotifier.value = null;
    trackLikeNotifier.value = false;
  }

  Future<void> login(String login, String password) async {
    final YmToken? result = await ymLogin(login, password);
    if(result == null) return;

    await _prefs.setAuthToken(result.accessToken);
    await _prefs.setExpiresIn(result.expiresIn.inSeconds);

    _musicApi.authToken = result.accessToken;
    _reset();
    await requestAccountData();
    requestStations();
  }

  Future<void> logout() async {
    _prefs.clear();
    _reset();
  }

  Future<void> requestAccountData() async {
    final accountStatus = await _musicApi.accountStatus();
    if(accountStatus.account == null) return;

    _musicApi.uid = accountStatus.account!.uid;
    accountNotifier.value = accountStatus.account;
  }

  Future<void> requestStations() async {
    final dashboard = await _musicApi.stationsDashboard();
    stationsNotifier.value = dashboard.stations;
  }
}
