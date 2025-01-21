import 'dart:async';

import 'package:audio_player_gst/events.dart';
import 'package:collection/collection.dart' hide binarySearch;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/tray_integration.dart';

import 'dbus/mpris/metadata.dart';
import 'dbus/mpris/mpris_player.dart';
import 'helpers/app_route_observer.dart';
import 'helpers/nav_keys.dart';
import 'notifiers/track_duration_notifier.dart';
import 'player/playback_queue.dart';
import 'player/player_base.dart';
import 'player/players_manager.dart';
import 'player/queue_factory.dart';
import 'services/preferences.dart';
import 'models/music_api_types.dart';
import 'music_api.dart';
import 'notifiers/play_button_notifier.dart';
import 'services/service_locator.dart';
import 'services/yandex_api_client.dart';
import 'audio_player.dart';
import 'state_enums.dart';
import 'window_manager.dart';

class AppState {
  // Listeners: Updates going to the UI
  late final ValueNotifier<ThemeData> themeNotifier;
  final mainPageState = ValueNotifier<UiState>(UiState.loading);
  late final progressNotifier = _audioPlayer.trackDurationNotifier;
  final playButtonNotifier = PlayButtonNotifier();
  final trackNotifier = ValueNotifier<Track?>(null);
  final currentStationNotifier = ValueNotifier<Station?>(null);
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
  final queueTracks = ValueNotifier<List<Track>>([]);
  final shuffleNotifier = ValueNotifier<bool>(false);
  final repeatNotifier = ValueNotifier<RepeatMode>(RepeatMode.off);
  final stationSettingsNotifier = ValueNotifier<Map<String, String>>({});
  final playbackSpeedNotifier = ValueNotifier<double>(1);
  late final volumeNotifier = _audioPlayer.volumeNotifier;
  // abilities
  final canGoNextNotifier = ValueNotifier<bool>(false);
  final canGoPreviousNotifier = ValueNotifier<bool>(false);
  final canPlayNotifier = ValueNotifier<bool>(false);
  final canPauseNotifier = ValueNotifier<bool>(false);
  final canSeekNotifier = ValueNotifier<bool>(false);
  final canShuffleNotifier = ValueNotifier<bool>(false);
  final canRepeatNotifier = ValueNotifier<bool>(false);
  // settings
  final closeToTrayEnabledNotifier = ValueNotifier<bool>(false);
  late final localeNotifier = ValueNotifier<Locale>(_prefs.locale);
  bool isQueueShown = false;

  final _musicApi = getIt<MusicApi>();
  final _prefs = getIt<Preferences>();
  final _audioPlayer = getIt<AudioPlayer>();
  final _playersManager = getIt<PlayersManager>();
  final _mpris = getIt<OrgMprisMediaPlayer2>();
  final _trayIntegration = TrayIntegration();
  final _windowManager = getIt<WindowManager>();

  final List<int> _likedTrackIds = [];
  final List<int> _likedArtistIds = [];
  final List<Tree> _landing3Metatags = [];

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
    _listenToShuffleState();
    _listenToRepeatState();
    _listenToRate();
    _listenToVolume();
    _listenToTrayEvents();
    _listenToPlayerAbilities();
    _listenToTrackChange();
    _listenToRouteChanges();
    _listenToSettingsChanges();

    if(_prefs.authToken == null) {
      mainPageState.value = UiState.auth;

      return;
    }

    getIt<YandexApiClient>().locale = _prefs.locale;

    await _requestAppData();
    mainPageState.value = UiState.main;
    _mpris.canShuffle = true;
    shuffleNotifier.value = _prefs.shuffle;
    _mpris.canRepeat = true;
    repeatNotifier.value = _prefs.repeat;
    volumeNotifier.value = _prefs.volume.clamp(0, 1);
    closeToTrayEnabledNotifier.value = _prefs.hideOnClose;
    _mpris.positionStream.listen(_audioPlayer.seek);

    _windowManager.backButtonStream.listen((_) => _onBackButtonClicked());
  }

  static const yaColor = Color.fromARGB(255, 254, 218, 76);
  Future<ThemeData> getTheme() async {
    final Map<String,Color> themeColors = await _windowManager.getThemeColors();

    final double luminance = themeColors['surface']!.computeLuminance();

    return ThemeData(
      primaryColor: yaColor,
      scaffoldBackgroundColor: themeColors['surface']!,
      colorScheme: ColorScheme.fromSeed(
        surface: themeColors['surface']!,
        seedColor: themeColors['textColor']!,
        brightness: luminance < 0.5 ? Brightness.dark : Brightness.light,
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

    await _requestInitialQueueData();
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

  Future<void> _requestLanding3Metatags() async {
    _landing3Metatags.clear();
    _landing3Metatags.addAll(await _musicApi.landing3Metatags());
  }

  void _listenToPlaybackState() {
    _audioPlayer.playingStateNotifier.addListener((){
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
        _mpris.playbackState = 'Stopped';
      }
    });
  }

  void _listenToMprisControlStream() {
    _mpris.controlStream.listen((event) {
      switch (event) {
        case 'play':
          _audioPlayer.play();
        case 'pause':
          _audioPlayer.pause();
        case 'playPause':
          if (_audioPlayer.playingStateNotifier.value == PlayingState.playing) {
            _audioPlayer.pause();
          }
          else {
            _audioPlayer.play();
          }
        case 'next':
          _playersManager.next();
        case 'previous':
          _playersManager.previous();
      }
    });
  }

  void _listenToTrackDurationNotifier() {
    _audioPlayer.trackDurationNotifier.addListener(() {
      final TrackDurationState state = _audioPlayer.trackDurationNotifier.value;
      _mpris.position = state.position;

    });
  }

  void _listenToShuffleState() {
    _mpris.shuffleStream.listen((bool value){
      shuffleNotifier.value = value;
    });

    shuffleNotifier.addListener((){
      _prefs.setShuffle(shuffleNotifier.value);
      _mpris.shuffle = shuffleNotifier.value;
    });
  }

  void _listenToRepeatState() {
    _mpris.repeatStream.listen((RepeatMode value){
      repeatNotifier.value = value;
    });

    repeatNotifier.addListener((){
      _prefs.setRepeat(repeatNotifier.value);
      _mpris.repeat = repeatNotifier.value;
    });
  }
  
  void _listenToRate() {
    _mpris.rateStream.listen((double value){
      playbackSpeedNotifier.value = value;
    });

    playbackSpeedNotifier.addListener((){
      _mpris.rate = playbackSpeedNotifier.value;
    });
  }

  void _listenToVolume() {
    volumeNotifier.addListener((){
      _prefs.setVolume(volumeNotifier.value);
      _audioPlayer.setVolume(volumeNotifier.value);
      _mpris.volume = volumeNotifier.value;
    });

    _mpris.volumeStream.listen((volume){
      volumeNotifier.value = volume;
    });
  }

  void _listenToTrayEvents() {
    _trayIntegration.playBackChangeStream.listen((PlayBackChangeType type){
      switch(type) {
        case PlayBackChangeType.playPause:
          // @TODO: нужно реализовать метод playPause() в PlayersManager
          if(playButtonNotifier.value == ButtonState.playing) {
            _playersManager.pause();
          }
          else if(playButtonNotifier.value == ButtonState.paused) {
            _playersManager.play();
          }
        case PlayBackChangeType.next:
          _playersManager.next();
        case PlayBackChangeType.prev:
          _playersManager.previous();
      }
    });

    _trayIntegration.scrollStream.listen((int delta){
      double volume = (volumeNotifier.value + delta / 5000.0).clamp(0, 1.0);
      volumeNotifier.value = volume;
    });
  }

  void _listenToPlayerAbilities() {
    canGoNextNotifier.addListener((){
      _mpris.canGoNext = canGoNextNotifier.value;
    });

    canGoPreviousNotifier.addListener((){
      _mpris.canGoPrevious = canGoPreviousNotifier.value;
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

  void _listenToTrackChange() {
    trackNotifier.addListener((){
      if(trackNotifier.value == null) return;

      Track track = trackNotifier.value!;
      _windowManager.setWindowTitle(track.title, track.artist);

      final trayTitle = 'YaPlayer\n${track.title} – ${track.artist}';
      _trayIntegration.setTitle(trayTitle);

      _setMprisMetagata(track);
    });
  }

  void _setMprisMetagata(Track track) {
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
    landingNotifier.value = await _musicApi.landing();
  }

  Future<void> _requestInitialQueueData() async {
    final List<String> queueIds = await _musicApi.queueIds();
    if(queueIds.isEmpty) return;

    final Queue queue = await _musicApi.queue(queueIds.first);
    if((queue.tracks.isEmpty || queue.currentIndex == null) && queue.context.type != 'radio') return;

    late final Track track;
    if(queue.context.type == 'radio') {
      final Station station = await _musicApi.station(StationId.fromString(queue.context.id!));
      final Iterable<Track> tracks = await _musicApi.stationTacks(station.id, []);
      final stationsQueue = StationQueue(station: station, initialData: (queue, tracks));
      final player = StationPlayer(queue: stationsQueue);
      _playersManager.setPlayer(player);
      currentStationNotifier.value = station;
      track = tracks.first;
      await _musicApi.sendStationTrackFeedback(station.id, null, 'radioStarted', null);
    }
    else {
      Iterable<TrackOfList> trackIds = queue.tracks.map(
              (t) => TrackOfList(int.parse(t.trackId), int.parse(t.albumId), DateTime.now()));
      queueTracks.value = await _musicApi.tracks(trackIds);
      final playbackQueue = TracksQueue(queue: queue, tracks: queueTracks.value);
      final player = TracksPlayer(queue: playbackQueue);
      _playersManager.setPlayer(player);
      track = playbackQueue.currentTrack;
    }

    trackNotifier.value = track;
    canPlayNotifier.value = true;
    canPauseNotifier.value = true;

    _setMprisMetagata(track);
  }

  Future<void> playContent(Object source, Iterable<Track> tracks, int? index) async {
    playButtonNotifier.value = ButtonState.loading;
    playbackSpeedNotifier.value = 1.0;
    index ??= 0;

    final Queue queue = await QueueFactory.create(
      tracksSource: source,
      currentIndex: index
    );

    queueTracks.value = tracks.toList();
    final playbackQueue = TracksQueue(queue: queue, tracks: tracks);
    final player = TracksPlayer(queue: playbackQueue);
    _playersManager.setPlayer(player);
    currentStationNotifier.value = null;
  }

  Future<void> playStation(Station station) async {
    playButtonNotifier.value = ButtonState.loading;
    playbackSpeedNotifier.value = 1.0;
    final Iterable<Track> tracks = await _musicApi.stationTacks(station.id, []);
    Queue queue = await QueueFactory.create(tracksSource: (station, tracks));
    final stationsQueue = StationQueue(station: station, initialData: (queue, tracks));
    final player = StationPlayer(queue: stationsQueue);

    _playersManager.setPlayer(player);
    _playersManager.play();
  }

  Future<void> playArtistStation(Artist artist) async {
    final stationId = StationId("artist", artist.id.toString());
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
