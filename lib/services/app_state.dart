import 'dart:async';
import 'package:audio_player_gst/events.dart';
import 'package:collection/collection.dart' hide binarySearch;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/models/music_api/context_id.dart';
import '/models/ynison/version.dart';
import '/player/radio_manager.dart';
import '/models/play_info.dart';
import '/services/logger.dart';
import '/models/ynison/player_state.dart';
import 'play_analytics.dart';
import 'tray_integration.dart';
import '/dbus/mpris/metadata.dart';
import '/dbus/mpris/mpris_player.dart';
import '/helpers/app_route_observer.dart';
import '/helpers/nav_keys.dart';
import '/notifiers/track_duration_notifier.dart';
import '/player/playback_queue.dart';
import '/player/player.dart';
import 'player_state.dart';
import 'preferences.dart';
import '/models/music_api_types.dart';
import 'music_api.dart';
import '/notifiers/play_button_notifier.dart';
import 'service_locator.dart';
import 'yandex_api_client.dart';
import 'audio_player.dart';
import 'state_enums.dart';
import 'window_manager.dart';
import 'ynison_client.dart';
import '/models/ynison/ynison_state.dart';

class AppState {
  // Listeners: Updates going to the UI
  late final ValueNotifier<ThemeData> themeNotifier;
  final mainPageState = ValueNotifier<UiState>(UiState.loading);
  final playButtonNotifier = PlayButtonNotifier();
  final currentStationNotifier = ValueNotifier<Station?>(null);
  final currentRadioNotifier = ValueNotifier<RadioSession?>(null);
  final stationsDashboardNotifier = ValueNotifier<List<Station>>([]);
  final stationsNotifier = ValueNotifier<Map<String,List<Station>>>({});
  final accountNotifier = ValueNotifier<Account?>(null);
  final likedTracksNotifier = ValueNotifier<List<Track>>([]);
  final albumsNotifier = ValueNotifier<List<Album>>([]);
  final artistsNotifier = ValueNotifier<List<Artist>>([]);
  final playlistsNotifier = ValueNotifier<List<Playlist>>([]);
  final albumNotifier = ValueNotifier<AlbumWithTracks?>(null);
  final searchSuggestionsNotifier = ValueNotifier<SearchSuggestions?>(null);
  final searchResultNotifier = ValueNotifier<SearchResult?>(null);
  final nonMusicNotifier = ValueNotifier<List<Block>>([]);
  final landingNotifier = ValueNotifier<List<Block>>([]);
  final trackNotifier = ValueNotifier<Track?>(null);
  final queueTracks = ValueNotifier<List<Track>>([]);
  final stationSettingsNotifier = ValueNotifier<Map<String, String>>({});

  // settings
  final closeToTrayEnabledNotifier = ValueNotifier<bool>(false);
  late final localeNotifier = ValueNotifier<Locale>(_prefs.locale);
  bool isQueueShown = false;

  final _musicApi = getIt<MusicApi>();
  final _prefs = getIt<Preferences>();
  final _audioPlayer = getIt<AudioPlayer>();
  final _playerState = getIt<PlayerState>();
  final _mpris = getIt<OrgMprisMediaPlayer2>();
  final _trayIntegration = TrayIntegration();
  final _windowManager = getIt<WindowManager>();
  final _queue = getIt<PlaybackQueue>();
  final _newPlayer = getIt<Player>();
  var _playContext = Object();
  final Map<String,String> _genres = {};
  final _playAnalytics = PlayAnalytics();
  late final YnisonClient _ynisonClient;
  late YPlayerState _ynisonState;
  final _radioManager = RadioManager();

  final List<String> _likedTrackIds = [];
  final List<int> _likedArtistIds = [];
  final List<Tree> _landing3Metatags = [];

  Object get playContext => _playContext;

  Future<void> initTheme() async {
    final ThemeData theme = await getTheme();
    themeNotifier = ValueNotifier<ThemeData>(theme);
  }

  // Events: Calls coming from the UI
  void init() async {
    _trayIntegration.init();
    _listenToPlaybackState();
    _listenToMprisControlStream();
    _listenToTrackDurationNotifier();
    _listenToTrayEvents();
    _listenToRouteChanges();
    _listenToSettingsChanges();

    if(_prefs.authToken == null) {
      mainPageState.value = UiState.auth;

      return;
    }

    getIt<YandexApiClient>().locale = _prefs.locale;
    _ynisonClient = YnisonClient(
      authToken: _prefs.authToken!,
      deviceId: _prefs.deviceId,
    );

    _playAnalytics.start();
    _listenToYnisonState();
    _listenToNewTrack();
    _listenToBeginPlaying();
    await _requestAppData();
    mainPageState.value = UiState.main;
    closeToTrayEnabledNotifier.value = _prefs.hideOnClose;
    _mpris.positionStream.listen(_audioPlayer.seek);

    _windowManager.backButtonStream.listen((_) => _onBackButtonClicked());
  }

  static const yaColor = Color.fromARGB(255, 254, 218, 76);
  Future<ThemeData> getTheme() async {
    final Map<String,Color> themeColors = await _windowManager.getThemeColors();

    return ThemeData(
      primaryColor: yaColor,
      scaffoldBackgroundColor: themeColors['surface']!,
      colorScheme: ColorScheme.fromSeed(
        surface: themeColors['surface']!,
        seedColor: themeColors['textColor']!,
        brightness: await _windowManager.getThemeType(),
        primary: yaColor,
        onSurface: themeColors['textColor']!,
      ),
      sliderTheme: SliderThemeData(
        inactiveTrackColor: themeColors['textColor']!.withAlpha(127),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states){
            if(states.contains(WidgetState.selected)) {
              return yaColor;
            }
            return themeColors['surface']!;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states){
            if(states.contains(WidgetState.selected)) {
              return themeColors['surface']!;
            }
            return themeColors['textColor']!;
          }),
        ),
      ),
    );
  }

  Future<void> _requestAppData() async {
    await _requestAccountData();
    await _requestTranslatedData();

    final List<Future> futures = [];
    futures.add(_requestLikedTracks());
    futures.add(_requestLikedAlbums());
    futures.add(_requestArtists());
    await Future.wait(futures);

    // await _requestInitialQueueData();
  }

  Future<void> _requestTranslatedData() async {
    final List<Future> futures = [];
    futures.add(_requestStationsDashboard());
    futures.add(_requestStations());
    futures.add(_requestPlaylists());
    await Future.wait(futures);

    futures.add(_requestNonMusicCatalog());
    futures.add(_requestLanding());
    futures.add(_requestLanding3Metatags());
    await Future.wait(futures);

    futures.add(_requestGenres());
    await Future.wait(futures);
  }

  Future<void> _requestLikedTracks() async {
    if(_prefs.authToken == null) return;

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
      _likedTrackIds.sort();
    }
  }

  Future<void> _requestLanding3Metatags() async {
    _landing3Metatags.clear();
    _landing3Metatags.addAll(await _musicApi.landing3Metatags());
  }

  void _listenToPlaybackState() {
    _audioPlayer.playingStateNotifier.addListener(() async {
      final playingState = _audioPlayer.playingStateNotifier.value;
      if(playingState == PlayingState.paused) {
        playButtonNotifier.value = ButtonState.paused;
        _mpris.playbackState = 'Paused';
      }
      else if(playingState == PlayingState.playing) {
        playButtonNotifier.value = ButtonState.playing;
        _mpris.playbackState = 'Playing';
      }
      else if(playingState == PlayingState.completed) {
        playButtonNotifier.value = ButtonState.paused;
        _mpris.playbackState = 'Stopped';
      }
    });
  }

  void _listenToMprisControlStream() {
    _mpris.controlStream.listen((event) {
      switch (event) {
        case 'play':
          _newPlayer.play();
        case 'pause':
          _newPlayer.pause();
        case 'playPause':
          _newPlayer.playPause();
        case 'next':
          _newPlayer.next();
        case 'previous':
          _newPlayer.previous();
      }
    });
  }

  void _listenToTrackDurationNotifier() {
    _audioPlayer.trackDurationNotifier.addListener(() {
      final TrackDurationState state = _audioPlayer.trackDurationNotifier.value;
      _mpris.position = state.position;
    });
  }

  void _listenToTrayEvents() {
    _trayIntegration.playBackChangeStream.listen((PlayBackChangeType type){
      switch(type) {
        case PlayBackChangeType.playPause:
          _newPlayer.playPause();
        case PlayBackChangeType.next:
          _newPlayer.next();
        case PlayBackChangeType.prev:
          _newPlayer.previous();
      }
    });

    _trayIntegration.scrollStream.listen((int delta){
      double volume = (_audioPlayer.volumeNotifier.value + delta / 5000.0).clamp(0, 1.0);
      _audioPlayer.volumeNotifier.value = volume;
    });
  }

  void _setMprisMetadata(Track track) {
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
  }

  void _listenToRouteChanges() {
    getIt<AppRouteObserver>().popNotifier.addListener((){
      final bool isBackButtonVisible = NavKeys.mainNav.currentState?.canPop() == true;
      _windowManager.showBackButton(isBackButtonVisible);
    });
  }

  void _listenToSettingsChanges() {
    closeToTrayEnabledNotifier.addListener((){
      final bool value = closeToTrayEnabledNotifier.value;

      _windowManager.setHideOnClose(value);
      _prefs.setHideOnClose(value);
    });

    localeNotifier.addListener(() {
      getIt<YandexApiClient>().locale = localeNotifier.value;
      _prefs.setLocale(localeNotifier.value);
      _requestTranslatedData();
    });
  }

  late StreamSubscription _ynisonStateSubscription;
  void _listenToYnisonState() {
    _ynisonStateSubscription = _ynisonClient.stateStream.listen((YnisonState state) async {
      _ynisonStateSubscription.cancel();

      final YPlayerQueue playerQueue = state.playerState.playerQueue;
      List<Track> tracks = [];
      currentRadioNotifier.value = null;

      _ynisonState = state.playerState;

      if(playerQueue.entityType != PlayInfoContext.radio) {
        _ynisonState.playerQueue.queue = null;
      }

      switch(playerQueue.entityType){
        case PlayInfoContext.various:
          // TODO: Handle this case.
          throw UnimplementedError();
        case PlayInfoContext.album:
          final albumId = int.parse(state.playerState.playerQueue.entityId);
          final AlbumWithTracks albumWithTracks = await _musicApi.albumWithTracks(albumId);
          tracks = albumWithTracks.tracks;
          _playContext = albumWithTracks.album;
          _playerState.canShuffleNotifier.value = true;
          _playerState.canRepeatNotifier.value = true;
        case PlayInfoContext.artist:
          final ArtistInfo artistInfo = await _musicApi.artistInfo(int.parse(state.playerState.playerQueue.entityId));
          final ids = playerQueue.playableList.map((i) => i.playableId);
          tracks = await _musicApi.tracksByIds(ids);
          _playContext = artistInfo.artist;
          _playerState.canShuffleNotifier.value = true;
          _playerState.canRepeatNotifier.value = true;
        case PlayInfoContext.playlist:
          final [uid,kind] = playerQueue.entityId.split(':');
          final Playlist playlist = await _musicApi.playlist(int.parse(uid), int.parse(kind));
          _playContext = playlist;
          tracks = playlist.tracks;
          _playerState.canShuffleNotifier.value = true;
          _playerState.canRepeatNotifier.value = true;
        case PlayInfoContext.radio:
          final sessionId = playerQueue.queue!.waveQueue.entityOptions.waveEntity!.sessionId;
          final playables = playerQueue.playableList.take(playerQueue.currentPlayableIndex);
          final RadioSession session = await _radioManager.restore(
            sessionId: sessionId,
            queue: playables.map((i) => '${i.playableId}:${i.albumId}').toList(),
            seeds: playerQueue.entityId.split(','),
          );
          _playContext = session;
          currentRadioNotifier.value = session;
          _playerState.shuffleNotifier.value = false;
          _playerState.repeatModeNotifier.value = RepeatMode.off;

          final ids = playerQueue.playableList.map((i) => i.playableId);
          tracks = await _musicApi.tracksByIds(ids, session.batchId);

          if(ids.length != tracks.length) {
            logger.i('Received track ids are not the same as Requested ids:\n'
                '${ids.sorted().join(', ')}\n${tracks.map((t) => t.id).sorted().join(', ')}');
          }
      }

      // print(state.playerState.playerQueue.entityType.toString());
      // print('Tracks count: ${tracks.length}');

      tracks = tracks.where((t) => t.isAvailable).toList();
      int index = playerQueue.currentPlayableIndex;
      final selectedPlayable = playerQueue.playableList[index];
      index = tracks.indexWhere((t) => t.id == selectedPlayable.playableId);
      if(playerQueue.currentPlayableIndex != index) {
        logger.w('Queue indices differs!\n'
            'Saved index: ${playerQueue.currentPlayableIndex}\n'
            'Actual index: $index');
      }

      _queue.replaceTracks(tracks);
      _queue.moveTo(index);
      _queue.repeatMode = _prefs.repeat;
      _queue.isShuffleEnabled = _prefs.shuffle;

      final Track? track = _queue.currentTrack;
      if(track == null) return;

      await _newPlayer.loadTrack(track);
      _playerState.canPlayNotifier.value = true;
      _playerState.canPauseNotifier.value = true;
    });
  }

  void _listenToNewTrack() {
    _newPlayer.trackLoadedEvent.addHandler((Track track) async {
      trackNotifier.value = track;
      _windowManager.setWindowTitle(track.title, track.artist);
      _trayIntegration.setTooltip(track.title, track.artist);

      _setMprisMetadata(track);
    });
  }

  void _listenToBeginPlaying() {
    _newPlayer.beforeNewTrackStartedEvent.addHandler((Track track) async {
      _ynisonState.status = PlayerStateStatus(
        duration: track.duration!,
        isPaused: false,
        playbackSpeed: 1,
        progress: Duration.zero,
        version: Version(deviceId: _prefs.deviceId),
      );
      _ynisonState.playerQueue.currentPlayableIndex = _queue.currentIndex;
      logger.i('Current playable index: '
          '${_ynisonState.playerQueue.currentPlayableIndex} '
          'of ${_queue.tracks.length - 1}');
      _ynisonClient.sendPlayerUpdate(_ynisonState);
    });

    _queue.trackListChanged.addHandler((Iterable<Track> tracks) async {
      queueTracks.value = tracks.toList();
      
      _ynisonState.playerQueue.playableList.clear();
      _ynisonState.playerQueue.playableList.addAll(
        _queue.toPlayableList(PlayInfoRadio.defaultFrom),
      );
      _ynisonState.playerQueue.currentPlayableIndex = _queue.currentIndex;
      _ynisonState.status.version = Version(deviceId: _prefs.deviceId);
      _ynisonClient.sendPlayerUpdate(_ynisonState);
    });
  }

  void _onBackButtonClicked() {
    NavigatorState? navState = NavKeys.mainNav.currentState;
    if(navState == null) return;

    navState.pop();
    if(isQueueShown) {
      isQueueShown = false;
    }
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
    final List<Block> blocks = await _musicApi.landing();
    landingNotifier.value = blocks.where((b) => b.entities.isNotEmpty).toList();
  }

  Future<void> _requestGenres() async {
    final List<Genre> genres = await _musicApi.genres();
    _genres.clear();

    addGenres(List<Genre> genres) {
      for(Genre genre in genres) {
        _genres[genre.id] = genre.title;
        if(genre.subGenres.isNotEmpty) {
          addGenres(genre.subGenres);
        }
      }
    }

    addGenres(genres);
  }

  String? getGenreTitle(String id) => _genres[id];

  Future<Track?> _prepareAndPlay({
    required Object context,
    required Iterable<Track> tracks,
    int index = 0,
    shuffle = false,
    repeatMode = RepeatMode.off,
    canShuffle = true,
    canRepeat = true,
  }) async {
    _playContext = context;
    _queue.replaceTracks(tracks);
    _queue.moveTo(index);
    _queue.isShuffleEnabled = shuffle;
    _queue.repeatMode = repeatMode;

    final Track? track = _queue.currentTrack;
    if(track == null) return null;

    _playerState.canPlayNotifier.value = true;

    await _newPlayer.loadTrack(track);
    await _newPlayer.play();
    _playerState.canPauseNotifier.value = true;
    _playerState.canShuffleNotifier.value = canShuffle;
    _playerState.canRepeatNotifier.value = canRepeat;

    return track;
  }

  static const Map<Type, PlayInfoContext> _entityTypes = {
    Album: PlayInfoContext.album,
    Artist: PlayInfoContext.artist,
    Playlist: PlayInfoContext.playlist,
    Station: PlayInfoContext.radio,
    RadioSession: PlayInfoContext.radio,
    List<Track>: PlayInfoContext.playlist,
  };

  static const Map<Type, String> _entityFroms = {
    Album: 'desktop-own_collection-collection_new_albums-default',
    Artist: 'desktop-own_collection-collection_artists-default',
    Playlist: 'desktop-own_collection-collection_playlists-default',
    Station: 'desktop-home-rup_main-radio-default',
    RadioSession: 'desktop-home-rup_main-radio-default',
    List<Track>: 'desktop-own_collection-collection_playlists-default',
  };

  Future<void> playContent(Object contextObject, Iterable<Track> tracks, [int? index]) async {
    if(_playContext is RadioSession) _radioManager.stop();

    playButtonNotifier.value = ButtonState.loading;
    _playerState.rateNotifier.value = 1.0;
    index ??= 0;

    final Track? track = await _prepareAndPlay(
      context: contextObject,
      tracks: tracks,
      index: index,
      shuffle: _playerState.shuffleNotifier.value,
      repeatMode: _playerState.repeatModeNotifier.value,
    );

    if(track == null) return;

    _ynisonState = YPlayerState(
      playerQueue: YPlayerQueue(
        currentPlayableIndex: _queue.currentIndex,
        entityContext: 'BASED_ON_ENTITY_BY_DEFAULT',
        entityId: (_playContext as ContextId).contextId,
        entityType: _entityTypes[_playContext.runtimeType]!,
        from: _entityFroms[_playContext.runtimeType]!,
        options: QueueOptions(repeatMode: 'NONE'),
        playableList: _queue.toPlayableList(_entityFroms[_playContext.runtimeType]!).toList(),
        version: Version(deviceId: _prefs.deviceId),
      ),
      status: PlayerStateStatus(
        duration: track.duration!,
        isPaused: false,
        playbackSpeed: 1,
        progress: Duration.zero,
        version: Version(deviceId: _prefs.deviceId),
      ),
    );
    _ynisonClient.sendPlayerUpdate(_ynisonState);
  }

  Future<void> playStation(Station station) async {
    playButtonNotifier.value = ButtonState.loading;
    _playerState.rateNotifier.value = 1.0;

    final RadioSession radioSession = await _radioManager.start(station);
    final Track? track = await _prepareAndPlay(
      context: radioSession,
      tracks: radioSession.sequence.map((i) => i.track),
      canRepeat: false,
      canShuffle: false,
    );

    if(track == null) return;

    _ynisonState = YPlayerState(
      playerQueue: YPlayerQueue(
        currentPlayableIndex: _queue.currentIndex,
        entityContext: 'BASED_ON_ENTITY_BY_DEFAULT',
        entityId: track.id.toString(),
        entityType: _entityTypes[_playContext.runtimeType]!,
        from: PlayInfoRadio.defaultFrom,
        options: QueueOptions(repeatMode: 'NONE'),
        playableList: _queue.toPlayableList(PlayInfoRadio.defaultFrom).toList(),
        addingOptions: AddingOptions(
          radioOptions: RadioOptions(sessionId: radioSession.id),
        ),
        version: Version(deviceId: _prefs.deviceId),
      ),
      status: PlayerStateStatus(
        duration: track.duration!,
        isPaused: false,
        playbackSpeed: 1,
        progress: Duration.zero,
        version: Version(deviceId: _prefs.deviceId),
      ),
    );
    _ynisonClient.sendPlayerUpdate(_ynisonState);
  }

  Future<void> playTrack(Track track) async {
    playContent(track, [track]);
  }

  Future<void> playObjectStation(CanBeRadio object) async {
    final stationId = object.stationId();
    if(currentStationNotifier.value?.id == stationId) return;

    final station = await _musicApi.station(stationId);

    return playStation(station);
  }

  bool isLikedTrack(Track track) => binarySearch(_likedTrackIds, track.id) != -1;

  Future<void> likeTrack(Track track) async {
    int likedIndex = binarySearch(_likedTrackIds, track.id);
    final isLiked = likedIndex != -1;
    final Station? station = currentStationNotifier.value;

    if(isLiked) {
      await _musicApi.unlikeTrack(track);
      if(station != null) {
        await _musicApi.sendStationTrackFeedback(station.id, track, 'unlike', null);
      }
      _likedTrackIds.removeAt(likedIndex);
    }
    else {
      await _musicApi.likeTrack(track);
      if(station != null) {
        await _musicApi.sendStationTrackFeedback(station.id, track, 'like', null);
      }
      _likedTrackIds.add(track.id);
    }

    _likedTrackIds.sort();

    return _requestLikedTracks();
  }

  bool isLikedArtist(Artist artist) => binarySearch(_likedArtistIds, artist.id) != -1;

  Future<void> likeArtist(Artist artist) async {
    int likedIndex = binarySearch(_likedArtistIds, artist.id);
    final isLiked = likedIndex != -1;

    if(isLiked) {
      await _musicApi.unlikeArtist(artist.id);
      _likedArtistIds.removeAt(likedIndex);
    }
    else {
      await _musicApi.likeArtist(artist.id);
      _likedArtistIds.add(artist.id);
    }

    _likedArtistIds.sort();
  }

  Tree? getTree(String id) {
    if(id == 'newbies') {
      return _landing3Metatags.firstWhereOrNull((i) => i.navigationId == 'genres');
    }

    if(id == 'in the mood') {
      return _landing3Metatags.firstWhereOrNull((i) => i.navigationId == 'moods');
    }

    if(id == 'background') {
      return _landing3Metatags.firstWhereOrNull((i) => i.navigationId == 'activities');
    }

    return null;
  }

  void _reset() {
    _audioPlayer.stop();
    playButtonNotifier.value = ButtonState.paused;
    trackNotifier.value = null;
    currentStationNotifier.value = null;
    stationsDashboardNotifier.value = [];
    accountNotifier.value = null;
    likedTracksNotifier.value = [];
    albumsNotifier.value = [];
    artistsNotifier.value = [];
    playlistsNotifier.value = [];
    nonMusicNotifier.value = [];
    landingNotifier.value = [];
    _radioManager.stop();
  }

  Future<void> login(String authToken) async {
    await _prefs.setAuthToken(authToken);
    getIt<YandexApiClient>().authToken = authToken;
    mainPageState.value = UiState.loading;

    await _requestAppData();

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
