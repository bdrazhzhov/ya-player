import 'dart:async';

import 'package:audio_player_gst/events.dart';
import 'package:collection/collection.dart' hide binarySearch;
import 'package:flutter/foundation.dart';
import 'package:ya_player/tray_integration.dart';

import 'dbus/mpris/metadata.dart';
import 'dbus/mpris/mpris_player.dart';
import 'helpers/nav_keys.dart';
import 'player/playback_queue.dart';
import 'player/player_base.dart';
import 'player/players_manager.dart';
import 'player/queue_factory.dart';
import 'services/preferences.dart';
import 'models/music_api_types.dart';
import 'music_api.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'services/service_locator.dart';
import 'helpers/ym_login.dart';
import 'services/yandex_api_client.dart';
import 'audio_player.dart';
import 'state_enums.dart';

class AppState {
  // Listeners: Updates going to the UI
  final mainPageState = ValueNotifier<UiState>(UiState.loading);
  final progressNotifier = ProgressNotifier();
  final playButtonNotifier = PlayButtonNotifier();
  final trackNotifier = ValueNotifier<Track?>(null);
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
  final shuffleNotifier = ValueNotifier<bool>(false);
  final repeatNotifier = ValueNotifier<RepeatMode>(RepeatMode.off);
  final stationSettingsNotifier = ValueNotifier<Map<String, String>>({});
  final playbackSpeedNotifier = ValueNotifier<double>(1);

  final _musicApi = getIt<MusicApi>();
  final _prefs = getIt<Preferences>();
  final _audioPlayer = getIt<AudioPlayer>();
  final _playersManager = getIt<PlayersManager>();
  final _mpris = getIt<OrgMprisMediaPlayer2>();
  final _trayIntegration = TrayIntegration();

  final List<int> _likedTrackIds = [];

  // Events: Calls coming from the UI
  void init() async {
    _trayIntegration.init();
    _listenToPlaybackState();
    _listenToShuffleState();
    _listenToRepeatState();
    _listenToRate();

    await _audioPlayer.setVolume(_prefs.volume);
    if(_prefs.authToken == null) {
      mainPageState.value = UiState.auth;

      return;
    }

    shuffleNotifier.value = _prefs.shuffle;
    repeatNotifier.value = _prefs.repeat;

    await _requestAppData();
    mainPageState.value = UiState.main;
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
    futures.add(_requestInitialQueueData());

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
    _audioPlayer.playbackEventMessageStream.listen((PlaybackEventMessage msg){
      progressNotifier.value = ProgressBarState(
        current: msg.position,
        buffered: msg.bufferedPosition,
        total: msg.duration ?? Duration.zero,
      );

      final playingState = msg.playingState;
      if(playingState == PlayingState.paused) {
        playButtonNotifier.value = ButtonState.paused;
      } else if(playingState == PlayingState.playing) {
        playButtonNotifier.value = ButtonState.playing;
      }
    });
  }

  void _listenToShuffleState() {
    _mpris.shuffleStream.listen((bool value){
      shuffleNotifier.value = value;
    });

    shuffleNotifier.addListener((){
      _prefs.setShuffle(shuffleNotifier.value);
    });
  }

  void _listenToRepeatState() {
    _mpris.repeatStream.listen((RepeatMode value){
      repeatNotifier.value = value;
    });

    repeatNotifier.addListener((){
      _prefs.setRepeat(repeatNotifier.value);
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


  Future<void> playContent(Object source, Iterable<Track> tracks, int? index) async {
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

  bool isLikedTrack(Track track) => binarySearch(_likedTrackIds, track.id) != -1;

  Future<void> likeTrack(Track track) async {
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

    return _requestLikedTracks();
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
