import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart' hide binarySearch;
import 'package:flutter/foundation.dart';

import 'models/music_api/album.dart';
import 'models/music_api/artist.dart';
import 'models/music_api/playlist.dart';
import 'models/music_api/search.dart';
import 'services/preferences.dart';
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
  final stationsDashboardNotifier = ValueNotifier<List<Station>>([]);
  final stationsNotifier = ValueNotifier<Map<String,List<Station>>>({});
  final accountNotifier = ValueNotifier<Account?>(null);
  final likedTracksNotifier = ValueNotifier<List<Track>>([]);
  final albumsNotifier = ValueNotifier<List<Album>>([]);
  final artistsNotifier = ValueNotifier<List<LikedArtist>>([]);
  final playlistsNotifier = ValueNotifier<List<Playlist>>([]);
  final albumNotifier = ValueNotifier<AlbumWithTracks?>(null);
  final searchSuggestionsNotifier = ValueNotifier<SearchSuggestions?>(null);
  final searchResultNotifier = ValueNotifier<SearchResult?>(null);
  final List<Track> playlist = [];

  final _audioHandler = getIt<MyAudioHandler>();
  final _musicApi = getIt<MusicApi>();
  int _currentIndex = -1;
  PlayInfo? _currentPlayInfo;
  final _prefs = getIt<Preferences>();
  late final List<int> _likedTrackIds;

  // Events: Calls coming from the UI
  void init() async {
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToSkipEvents();

    volume = _prefs.volume;
    
    await _requestAccountData();
    _requestStationsDashboard();
    _requestStations();
    _requestLikedTracks();
    _requestLikedAlbums();
    _requestArtists();
    _requestPlaylists();
  }

  Future<void> _requestLikedTracks() async {
    if((_prefs.authToken?.length ?? 0) == 0) return;

    final resultTuple = await _musicApi.likedTrackIds(revision: _prefs.likedTracksRevision);

    if(resultTuple.revision != null) {
      _likedTrackIds = resultTuple.ids;
      await _prefs.setLikedTracks(_likedTrackIds);
      await _prefs.setLikedTracksRevision(resultTuple.revision!);
    }
    else {
      _likedTrackIds = _prefs.likedTracks;
    }

    if(_likedTrackIds.isNotEmpty) {
      likedTracksNotifier.value = await _musicApi.likedTracks(_likedTrackIds);
      _likedTrackIds.sort();
    }
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) async {
      // debugPrint('PlaybackState: $playbackState');
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
        await _audioHandler.stop();
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

  Future<void> _requestLikedAlbums() async {
    albumsNotifier.value = await _musicApi.likedAlbums();
  }

  Future<void> _requestArtists() async {
    artistsNotifier.value = await _musicApi.likedArtists();
  }

  Future<void> _requestPlaylists() async {
    playlistsNotifier.value = await _musicApi.playlists();
  }

  double get volume => _audioHandler.volume;
  set volume(double value) {
    _audioHandler.setVolume(value);
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

    Uri? artUri;
    if(track.coverUri != null) {
      artUri = MusicApi.imageUrl(track.coverUri!, '260x260');
    }

    final mediaItem = MediaItem(
      id: track.id.toString(),
      title: track.title,
      artist: track.artists.map((artist) => artist.name).join(', '),
      album: track.albums.first.title,
      duration: track.duration,
      artUri: artUri,
      extras: {'url': url}
    );

    _audioHandler.playTrack(mediaItem);
    trackNotifier.value = track;
    trackLikeNotifier.value = binarySearch(_likedTrackIds, track.id) != -1;
  }

  Future<void> _playStationTrack(Station station, Track track) async {
    if(_currentPlayInfo != null) {
      _currentPlayInfo!.totalPlayed = progressNotifier.value.current;
      final bool isSkipped = progressNotifier.value.current.inMilliseconds / track.duration!.inMilliseconds < 0.9;
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
    int likedIndex = binarySearch(_likedTrackIds, track.id);
    final isLiked = likedIndex != -1;

    if(isLiked) {
      await _musicApi.unlikeTrack(track);
      _likedTrackIds.removeAt(likedIndex);
    }
    else {
      await _musicApi.likeTrack(track);
      _likedTrackIds.add(track.id);
    }

    _likedTrackIds.sort();
    trackLikeNotifier.value = !isLiked;
  }

  void _reset() {
    stop();
    playlist.clear();
    _currentIndex = -1;
    _currentPlayInfo = null;
    playButtonNotifier.value = ButtonState.paused;
    trackNotifier.value = null;
    currentStationNotifier.value = null;
    stationsDashboardNotifier.value = [];
    accountNotifier.value = null;
    trackLikeNotifier.value = false;
    likedTracksNotifier.value = [];
    albumsNotifier.value = [];
    artistsNotifier.value = [];
    playlistsNotifier.value = [];
  }

  Future<void> login(String login, String password) async {
    final YmToken? result = await ymLogin(login, password);
    if(result == null) return;

    await _prefs.setAuthToken(result.accessToken);
    await _prefs.setExpiresIn(result.expiresIn.inSeconds);

    _musicApi.authToken = result.accessToken;
    _reset();
    await _requestAccountData();
    _requestStationsDashboard();
    _requestStations();
    _requestLikedTracks();
    _requestLikedAlbums();
    _requestArtists();
    _requestPlaylists();
  }

  Future<void> logout() async {
    _prefs.clear();
    _reset();
  }

  Future<void> _requestAccountData() async {
    final accountStatus = await _musicApi.accountStatus();
    if(accountStatus.account == null) return;

    _musicApi.uid = accountStatus.account!.uid;
    accountNotifier.value = accountStatus.account;
  }

  Future<void> _requestStationsDashboard() async {
    final dashboard = await _musicApi.stationsDashboard();
    stationsDashboardNotifier.value = dashboard.stations;
  }

  Future<void> _requestStations() async {
    final stations = await _musicApi.stationsList();

    if(stations.isEmpty) return;

    final groups = stations.groupListsBy((element) => element.id.type);
    final genres = groups['genre']!;

    for(Station station in genres) {
      if(station.parentId == null) continue;

      Station? parent = genres.firstWhereOrNull((genre) => genre.id == station.parentId);
      if(parent != null) parent.subStations.add(station);
    }
    genres.removeWhere((station) => station.parentId != null);

    stationsNotifier.value = groups;
  }

  Future<void> requestAlbumData(int albumId) async {
    albumNotifier.value = null;
    albumNotifier.value = await _musicApi.albumWithTracks(albumId);
  }

  void searchSuggestions(String text) async {
    searchSuggestionsNotifier.value = await _musicApi.searchSuggestions(text);
  }

  void searchResult(String text) async {
    searchResultNotifier.value = await _musicApi.searchResult(text: text);
  }
}
