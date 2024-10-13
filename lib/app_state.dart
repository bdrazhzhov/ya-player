import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart' hide binarySearch;
import 'package:flutter/foundation.dart';

import 'helpers/playback_queue.dart';
import 'helpers/nav_keys.dart';
import 'models/play_info.dart';
import 'services/preferences.dart';
import 'models/music_api_types.dart';
import 'music_api.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'services/audio_handler.dart';
import 'services/service_locator.dart';
import 'helpers/ym_login.dart';
import 'services/yandex_api_client.dart';

enum UiState { loading, auth, main }

class AppState {
  // Listeners: Updates going to the UI
  final mainPageState = ValueNotifier<UiState>(UiState.loading);
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
  final nonMusicNotifier = ValueNotifier<List<Block>>([]);
  final landingNotifier = ValueNotifier<List<Block>>([]);
  final queueTracks = ValueNotifier<List<Track>>([]);
  PlaybackQueue? _playbackQueue;

  final _audioHandler = getIt<MyAudioHandler>();
  final _musicApi = getIt<MusicApi>();
  PlayInfo? _currentPlayInfo;
  final _prefs = getIt<Preferences>();
  final List<int> _likedTrackIds = [];

  final _trackSkipStreamController = StreamController<TrackSkipType>();
  Stream<TrackSkipType> get trackSkipStream => _trackSkipStreamController.stream;

  // Events: Calls coming from the UI
  void init() async {
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToSkipEvents();

    volume = _prefs.volume;
    if(_prefs.authToken == null) {
      mainPageState.value = UiState.auth;

      return;
    }

    await _requestAppData();
    mainPageState.value = UiState.main;
  }

  void _listenToPreloadStream() {
    _playbackQueue?.preloadStream.listen((lastTrackIds) async {
      // When the playlist almost reached its end loading
      // new tracks and adding to the end of the playlist
      if(currentStationNotifier.value == null) return;

      final List<Track> tracks = await _musicApi.stationTacks(currentStationNotifier.value!.id, lastTrackIds);
      _playbackQueue!.addAll(tracks);
      debugPrint('Added tracks: ${tracks.map((e) => e.title)}');
    });
  }

  Future<void> _requestAppData() async {
    await _requestAccountData();

    final List<Future> futures = [];
    futures.add(_requestStationsDashboard());
    futures.add(_requestStations());
    futures.add(_requestLikedTracks());
    futures.add(_requestLikedAlbums());
    futures.add(_requestArtists());
    futures.add(_requestPlaylists());
    futures.add(_requestNonMusicCatalog());
    futures.add(_requestLanding());

    await Future.wait(futures);
  }

  Future<void> _requestLikedTracks() async {
    if((_prefs.authToken?.length ?? 0) == 0) return;

    final resultTuple = await _musicApi.likedTrackIds(revision: _prefs.likedTracksRevision);

    if(resultTuple.revision != null) {
      _likedTrackIds.clear();
      _likedTrackIds.addAll(resultTuple.ids);
      await _prefs.setLikedTracks(_likedTrackIds);
      await _prefs.setLikedTracksRevision(resultTuple.revision!);
    }
    else {
      _likedTrackIds.clear();
      _likedTrackIds.addAll(_prefs.likedTracks);
    }

    if(_likedTrackIds.isNotEmpty) {
      likedTracksNotifier.value = await _musicApi.tracksByIds(_likedTrackIds);
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
        await _audioHandler.stop();
        _trackSkipStreamController.add(TrackSkipType.next);
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
      _trackSkipStreamController.add(event);
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

  Future<void> _requestNonMusicCatalog() async {
    nonMusicNotifier.value = await _musicApi.nonMusicCatalog();
  }

  Future<void> _requestLanding() async {
    landingNotifier.value = await _musicApi.landing();
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

  // Future<void> previous() async {
  //   Track? track = _playbackQueue?.previous();
  //   if(track == null) return;
  //
  //   _playTrack(track);
  // }
  // void previous() {
  //   _playerEventsStreamController.add(PlayerEvent.previous);
  // }

  // Future<void> next() async {
  //   Track? track = _playbackQueue?.next();
  //   if(track == null) return;
  //
  //   _playTrack(track);
  // }

  // void next() {
  //   _playerEventsStreamController.add(PlayerEvent.next);
  // }

  Future<void> playStationTracks(Station station) async {
    currentStationNotifier.value = station;
    String stationId = station.id.type != 'user' ? '${station.id.type}_' : '';
    stationId += station.id.tag;
    final String queueName = 'desktop_win-radio-radio_$stationId-default';

    if(_playbackQueue?.name != queueName) {
      final lastTrackIds = _playbackQueue?.lastTrackIds() ?? [];
      final List<Track> tracks = await _musicApi.stationTacks(station.id, lastTrackIds);

      trackMapper(track) => QueueTrack(
        track.id.toString(),
        track.firstAlbumId.toString(),
        queueName
      );
      final List<QueueTrack> queueTracks = tracks.map(trackMapper).toList();

      final queueId = await _musicApi.createQueueForStation(station, queueTracks);
      _playbackQueue = PlaybackQueue(tracks: tracks, id: queueId, name: queueName);

      _listenToPreloadStream();
    }

    Track? track = _playbackQueue!.moveTo(0);

    if(track != null) return _playTrack(track);
  }

  Future<void> playTracks(List<Track> tracks, int selectedIndex, String queueName) async {
    if(_playbackQueue?.name != queueName) {
      currentStationNotifier.value = null;
      _playbackQueue = await _createPlayingQueue(
        tracks: tracks,
        selectedIndex: selectedIndex,
        from: queueName,
      );
    }

    Track? track = _playbackQueue!.moveTo(selectedIndex);

    if(track == null) return;

    if(track == trackNotifier.value) {
      play();
    }
    else {
      return _playTrack(track);
    }
  }

  Future<PlaybackQueue> _createPlayingQueue({
    required List<Track> tracks,
    int selectedIndex = 0,
    required String from
  }) async {
    final validTracks = tracks.where((track) => track.isAvailable).toList();
    final tracksInQueue = validTracks.map((track) => QueueTrack(
      track.id.toString(),
      track.albums.first.id.toString(),
      from
    )).toList();
    final String queueId = await _musicApi.createQueueForLikedTracks(tracksInQueue, selectedIndex);
    queueTracks.value = tracks;

    return PlaybackQueue(tracks: validTracks, id: queueId, name: from);
  }

  Future<void> _playTrack(Track track) async {
    if(_currentPlayInfo != null) {
      _currentPlayInfo!.totalPlayed = progressNotifier.value.current;
      if(currentStationNotifier.value != null) {
        final bool isSkipped = progressNotifier.value.current.inMilliseconds / track.duration!.inMilliseconds < 0.9;
        final String feedback = isSkipped ? 'skip' : 'trackFinished';
        _musicApi.sendStationTrackFeedback(currentStationNotifier.value!.id,
            _currentPlayInfo!.track, feedback, _currentPlayInfo!.totalPlayed);
      }
      _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    }
    String? url = await _musicApi.trackDownloadUrl(track.id);

    if(url == null) return;

    Uri? artUri;
    if(track.coverUri != null) {
      artUri = Uri.parse(MusicApi.imageUrl(track.coverUri!, '260x260'));
    }

    final mediaItem = MediaItem(
      id: track.id.toString(),
      title: track.title,
      artist: track.artist,
      album: track.albums.first.title,
      duration: track.duration,
      artUri: artUri,
      extras: {'url': url}
    );

    _audioHandler.playTrack(mediaItem);
    trackNotifier.value = track;
    trackLikeNotifier.value = isLikedTrack(track);
    _currentPlayInfo = PlayInfo(track, _playbackQueue!.name);

    if(currentStationNotifier.value != null) {
      _musicApi.sendStationTrackFeedback(currentStationNotifier.value!.id,
          _currentPlayInfo!.track, 'trackStarted', _currentPlayInfo!.totalPlayed);
    }
    _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    _musicApi.updateQueuePosition(_playbackQueue!.id, _playbackQueue!.currentIndex);
  }

  bool isLikedTrack(Track track) => binarySearch(_likedTrackIds, track.id) != -1;

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
    _playbackQueue = null;
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
    nonMusicNotifier.value = [];
    landingNotifier.value = [];
  }

  Future<void> login(YmToken token) async {
    await _prefs.setAuthToken(token.accessToken);
    final expiresAt = DateTime.now().add(Duration(seconds: token.expiresIn.inSeconds));
    await _prefs.setExpiresAt(expiresAt.millisecondsSinceEpoch ~/ 1000);

    getIt<YandexApiClient>().authToken = token.accessToken;
    _requestAppData();
    mainPageState.value = UiState.main;
    NavKeys.mainNav.currentState?.pushReplacementNamed('/');
  }

  Future<void> logout() async {
    _prefs.clear();
    getIt<YandexApiClient>().authToken = '';
    accountNotifier.value = null;
    _reset();
    mainPageState.value = UiState.auth;
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

  void searchSuggestions(String text) async {
    searchSuggestionsNotifier.value = await _musicApi.searchSuggestions(text);
  }

  void searchResult(String text) async {
    searchResultNotifier.value = await _musicApi.searchResult(text: text);
  }

  Future<List<Track>> popularTracks(int artistId) async {
    final trackIds = await _musicApi.trackIdsByRating(artistId);
    return _musicApi.tracksByIds(trackIds);
  }
}
