import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:ya_player/helpers/date_extensions.dart';

import '/models/music_api/paged_data.dart';
import '/models/music_api_types.dart';
import '/models/play_info.dart';
import 'service_locator.dart';
import 'yandex_api_client.dart';

enum AlbumsSortBy { rating, year }

enum AlbumsSortOrder { desc, asc }

enum LyricsFormat { lrc, text }

final class QueueIndexInvalid implements Exception {}

class MusicApi {
  static const String _newMagicSalt = 'kzqU4XhfCaY6B6JTHODeq5';
  int uid;
  late final YandexApiClient _http;

  MusicApi(this.uid) {
    _http = getIt<YandexApiClient>();
  }

  Future<StationsDashboard> stationsDashboard() async {
    Map<String, dynamic> json = await _http.get('/rotor/stations/dashboard');
    return StationsDashboard.fromJson(json);
  }

  Future<Iterable<Station>> stationsList() async {
    List<dynamic> json = await _http.get('/rotor/stations/list');

    return json.map((item) => Station.fromJson(item['station'], item['settings2']));
  }

  Future<Iterable<Track>> stationTacks(StationId stationId, Iterable<String> queueTracks) async {
    String url = '/rotor/station/${stationId.type}:${stationId.tag}/tracks?settings2=true';
    if (queueTracks.isNotEmpty) {
      url += '&queue=${queueTracks.join('%2C')}';
    }
    Map<String, dynamic> json = await _http.get(url);

    return json['sequence'].map((item) => Track.fromJson(item, json['batchId']));
  }

  Future<Station> station(StationId stationId) async {
    final url = '/rotor/station/${stationId.type}:${stationId.tag}/info';
    List<dynamic> json = await _http.get(url);

    return Station.fromJson(json.first['station'], json.first['settings2']);
  }

  Future<void> updateStationSettings2(StationId stationId, Map<String, String> settings2) async {
    final url = '/rotor/station/${stationId.type}:${stationId.tag}/settings2';
    await _http.postJson(url, data: settings2);
  }

  static const _formats = ['flac', 'aac', 'he-aac', 'mp3', 'flac-mp4', 'aac-mp4', 'he-aac-mp4'];

  Future<UrlData> trackDownloadUrl(String trackId) async {
    final int ts = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
    final Uint8List key = utf8.encode(_newMagicSalt);
    final Uint8List data = utf8.encode('$ts${trackId}lossless${_formats.join()}encraw');
    final Digest digest = Hmac(sha256, key).convert(data);
    final String sign = base64.encode(digest.bytes);
    final query = {
      'ts': ts,
      'trackId': trackId,
      'quality': 'lossless',
      'codecs': _formats.join(','),
      'transports': 'encraw',
      'sign': sign.substring(0, sign.length - 1)
    };

    Map<String, dynamic> json = await _http.get('/get-file-info',
        headers: {'X-Yandex-Music-Client': 'YandexMusicDesktopAppWindows/5.34.1'},
        queryParameters: query);

    String? encryptionKey;
    if (json['downloadInfo']['key'] != null) {
      encryptionKey = json['downloadInfo']['key'].toString();
    }
    return UrlData(url: json['downloadInfo']['url'].toString(), encryptionKey: encryptionKey);
  }

  static String imageUrl(String placeholder, String dimensions) {
    return 'https://${placeholder.replaceAll('%%', dimensions)}';
  }

  Future<void> sendStationTrackFeedback(
      StationId stationId, Track? track, String feedbackType, Duration? totalPlayedSeconds) async {
    final data = {
      'type': feedbackType,
      // известны следующие значения: radioStarted, trackStarted, trackFinished, skip, like, unlike
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    String url = '/rotor/station/${stationId.type}:${stationId.tag}/feedback';

    if (track != null) {
      data['trackId'] = track.fullId;
      if (track.batchId.isNotEmpty) {
        url += '?batch-id=${track.batchId}';
      }
    }

    if (totalPlayedSeconds != null && totalPlayedSeconds.inSeconds > 0) {
      data['totalPlayedSeconds'] = (totalPlayedSeconds.inMilliseconds / 1000.0).toString();
    }

    await _http.postJson(url, data: data);
  }

  Future<void> sendPlayingStatistics(Map<String, String> playInfo) async {
    playInfo['uid'] = uid.toString();
    await _http.postForm('/play-audio', data: playInfo);
  }

  Future<void> likeTrack(Track track) async {
    final url = '/users/$uid/likes/tracks/add-multiple';
    final data = {'track-ids': track.fullId};
    await _http.postForm(url, data: data);
  }

  Future<void> unlikeTrack(Track track) async {
    final data = {'track-ids': track.fullId};
    await _http.postForm('/users/$uid/likes/tracks/remove', data: data);
  }

  Future<({Iterable<String> ids, int? revision})> likedTrackIds({int revision = 0}) async {
    final url = '/users/$uid/likes/tracks?if-modified-since-revision=$revision';
    final result = await _http.get(url);

    if (result == 'no-updates') {
      return (ids: <String>[], revision: null);
    }

    final json = result as Map<String, dynamic>;
    int newRevision = json['library']['revision'];
    List<String> ids = [];
    for (final item in json['library']['tracks']) {
      ids.add(item['id']);
    }

    return (ids: ids, revision: newRevision);
  }

  Future<Playlist> likedTracksPlaylist() async {
    Map<String, dynamic> json =
        await _http.get('/landing-blocks/collection/playlist-with-likes?count=1');
    final int kind = json['playlist']['kind'];

    return playlist(uid, kind);
  }

  Future<List<Track>> tracksByIds(Iterable<String> ids, [batchId = '']) async {
    final data = {'track-ids': ids.join(','), 'with-positions': 'True'};
    List<dynamic> json = await _http.postForm('/tracks', data: data);

    return json.map((item) => Track.fromJson(item, batchId)).toList();
  }

  Future<List<Track>> tracks(Iterable<TrackOfList> ids, [batchId = '']) async {
    final String trackIds = ids.map((e) => '${e.id}:${e.albumId}').join(',');
    final data = {'track-ids': trackIds, 'with-positions': 'True'};
    List<dynamic> json = await _http.postForm('/tracks', data: data);

    return json.map((item) => Track.fromJson(item, batchId)).toList();
  }

  Future<List<Album>> likedAlbums() async {
    List<dynamic> json = await _http.get('/users/$uid/likes/albums?rich=true');

    return json.map((item) => Album.fromJson(item['album'])).toList();
  }

  Future<List<Artist>> likedArtists() async {
    List<dynamic> json = await _http.get('/users/$uid/likes/artists?with-timestamps=true');

    return json.map((item) => Artist.fromJson(item['artist'])).toList();
  }

  Future<List<Playlist>> playlistsWithTracks() async {
    Iterable<int> kinds = await _playlistKinds();
    List<dynamic> json =
        await _http.postForm('/users/$uid/playlists', data: {'kinds': kinds.join(',')});

    return json.map((item) => Playlist.fromJson(item)).toList();
  }

  Future<List<Playlist>> playlists() async {
    List json = await _http.get('/users/$uid/playlists/list');

    return json.map((item) => Playlist.fromJson(item)).toList();
  }

  // Future<String> createQueue(Queue queue) async {
  Future<Queue> createQueue({
    required QueueContext context,
    required Iterable<QueueTrack> tracks,
    required bool isInteractive,
    String? from,
    int? currentIndex,
  }) async {
    Map<String, dynamic> data = {
      'context': context.toMap(),
      'currentIndex': currentIndex,
      'from': from,
      'tracks': tracks,
      'isInteractive': isInteractive
    };
    final result = await _http.postJson('/queues', data: data);
    final String queueId = result['id'].toString();

    return Queue(
        id: queueId,
        context: context,
        tracks: tracks,
        currentIndex: currentIndex,
        isInteractive: isInteractive,
        from: from);
  }

  Future<Iterable<int>> _playlistKinds() async {
    List<dynamic> json = await _http.get('/users/$uid/playlists/list');

    return json.map((item) => item['kind']);
  }

  Future<AccountStatus> accountStatus() async {
    Map<String, dynamic> json = await _http.get('/account/status');

    Account? account;
    if (json['account']['uid'] != null) {
      account = Account.fromJson(json['account']);
    }

    return AccountStatus(account);
  }

  Future<void> updateQueuePosition(String queueId, int position, bool isInteractive) async {
    final isInteractiveString = isInteractive ? 'True' : 'False';
    final url = '/queues/$queueId/update-position?currentIndex=$position'
        '&isInteractive=$isInteractiveString';
    try {
      await _http.postForm(url);
    } on DioException catch (e) {
      if (e.response == null) rethrow;

      final resp = e.response!;
      if (resp.statusCode == 400 && resp.data['message'] == 'currentIndex is invalid') {
        throw QueueIndexInvalid();
      } else {
        rethrow;
      }
    }
  }

  Future<Queue> createQueueForStation(Station station, List<QueueTrack> tracks) {
    final from =
        station.id.type == 'user' ? station.id.tag : "${station.id.type}_${station.id.tag}";
    final context = QueueContext(
        description: station.name, id: '${station.id.type}:${station.id.tag}', type: 'radio');

    return createQueue(
        context: context,
        currentIndex: null,
        from: 'desktop_win-radio-radio_$from-default',
        isInteractive: false,
        tracks: tracks);
  }

  Future<Queue> createQueueForLikedTracks(List<QueueTrack> tracks, int currentIndex) {
    const context = QueueContext(description: '', id: 'fonoteca', type: 'my_music');

    return createQueue(
        context: context, currentIndex: currentIndex, isInteractive: true, tracks: tracks);
  }

  Future<Queue> createQueueForAlbum(Album album, List<QueueTrack> tracks, int currentIndex) {
    return createQueue(
        context: QueueContext(description: album.title, id: album.id.toString(), type: 'album'),
        currentIndex: currentIndex,
        isInteractive: true,
        tracks: tracks);
  }

  Future<Queue> createQueueForPlaylist(
      Playlist playlist, List<QueueTrack> tracks, int currentIndex) {
    return createQueue(
        context: QueueContext(
            description: playlist.title, id: '${playlist.uid}:${playlist.kind}', type: 'my_music'),
        currentIndex: currentIndex,
        isInteractive: true,
        tracks: tracks);
  }

  Future<AlbumWithTracks> albumWithTracks(int albumId) async {
    Map<String, dynamic> json = await _http.get(
      '/albums/$albumId/with-tracks',
      cacheDuration: const Duration(days: 1),
    );
    final result = AlbumWithTracks.fromJson(json);

    return result;
  }

  Future<ArtistInfo> artistInfo(String artistId) async {
    Map<String, dynamic> json = await _http.get('/artists/$artistId/brief-info');
    final result = ArtistInfo.fromJson(json);

    return result;
  }

  Future<SearchSuggestions> searchSuggestions(String text) async {
    Map<String, dynamic> json = await _http.get('/search/suggest?part=$text');
    final result = SearchSuggestions.fromJson(json);

    return result;
  }

  Future<SearchResult> searchResult(
      {required String text, String type = 'all', int page = 0}) async {
    final url = '/search?text=${Uri.encodeComponent(text)}'
        '&nocorrect=false&type=$type&page=$page&playlist-in-best=true';
    Map<String, dynamic> json = await _http.get(url);

    return SearchResult.fromJson(json);
  }

  Future<SearchResultMixed> searchMixed({required String text, SearchFilter? filter}) async {
    var query = {
      'text': text,
      'type': 'album,artist,playlist,track,wave,podcast,podcast_episode',
      'page': 0,
      'pageSize': 36,
      'withLikesCount': true,
      'withBestResults': true,
    };
    if (filter != null) {
      query['filter'] = filter.name;
    }
    Map<String, dynamic> json = await _http.get('/search/instant/mixed',
        queryParameters: query, cacheDuration: const Duration(minutes: 5));

    List<Object> items = [];
    if (json['results'] != null) {
      json['results'].forEach((item) {
        final Object? result = createSearchResultEntry(item);
        if (result == null) return;

        items.add(result);
      });
    }

    List<Object> bestResults = [];
    if (json['bestResults'] != null) {
      json['bestResults'].forEach((item) {
        if (item['type'] == 'best_result_artist') {
          bestResults.add(BestResultArtist.fromJson(item['best_result_artist']));
        } else if (item['type'] == 'best_result_wave') {
          bestResults.add(BestResultWave.fromJson(item['best_result_wave']));
        } else if (item['type'] == 'best_result_recent_release') {
          bestResults.add(BestResultRecentRelease.fromJson(item['best_result_recent_release']));
        }
      });
    }

    return SearchResultMixed(
      page: 0,
      perPage: 36,
      total: json['total'],
      filter: filter,
      items: items,
      bestResults: bestResults,
    );
  }

  static const List<String> skippedBlockIds = [
    'CONTINUE_LISTEN',
    'nonmusic-menu-tab',
    'bookmate_banner'
  ];

  Future<List<Block>> nonMusicCatalog() async {
    Map<String, dynamic> json = await _http.get('/non-music/catalogue');
    List<Block> blocks = [];

    json['blocks'].forEach((blockJson) {
      if (skippedBlockIds.contains(blockJson['id'])) return;

      blocks.add(Block.fromJson(blockJson));
    });

    return blocks;
  }

  Future<List<Block>> landing() async {
    const url = '/landing3?blocks=personalplaylists,promotions,new-releases,'
        'new-playlists,chart,charts,artists,albums,playlists,play_contexts,podcasts';
    // 'new-playlists,mixes,chart,charts,artists,albums,playlists,play_contexts,podcasts';
    Map<String, dynamic> json = await _http.get(url);
    List<Block> blocks = [];

    json['blocks'].forEach((blockJson) {
      if (blockJson['type'] == 'charts') return;

      blocks.add(Block.fromJson(blockJson));
    });

    return blocks;
  }

  Future<Playlist> playlist(int uid, int kind) async {
    Map<String, dynamic> json = await _http.get('/users/$uid/playlists/$kind');

    return Playlist.fromJson(json);
  }

  Future<List<String>> queueIds() async {
    Map<String, dynamic> json = await _http.get('/queues');

    return json['queues'].map((q) => q['id']);
  }

  Future<Queue> queue(String id) async {
    Map<String, dynamic> json = await _http.get('/queues/$id');

    return Queue.fromJson(json);
  }

  Future<List<String>> trackIdsByRating(String artistId) async {
    Map<String, dynamic> json = await _http.get('/artists/$artistId/track-ids-by-rating');

    return json['tracks'];
  }

  Future<PagedData<Album>> artistAlbums(
      {required String artistId,
      page = 0,
      perPage = 50,
      AlbumsSortBy sortBy = AlbumsSortBy.rating,
      AlbumsSortOrder sortOrder = AlbumsSortOrder.desc}) async {
    final sortByString = sortBy.toString().split('.').last;
    final sortOrderString = sortOrder.toString().split('.').last;
    final String url = '/artists/$artistId/direct-albums?page=$page'
        '&page-size=$perPage&sort-by=$sortByString&sort-order=$sortOrderString';
    Map<String, dynamic> json = await _http.get(url);
    final albums = json['albums'].map((a) => Album.fromJson(a));

    return PagedData.fromJson(json['pager'], albums);
  }

  Future<PagedData<Album>> artistAlsoAlbums(
      {required String artistId, page = 0, perPage = 50}) async {
    final String url = '/artists/$artistId/also-albums?page=$page&page-size=$perPage';
    Map<String, dynamic> json = await _http.get(url);
    final albums = json['albums'].map((a) => Album.fromJson(a));

    return PagedData.fromJson(json['pager'], albums);
  }

  Future<List<Track>> artistPopularTracks(String artistId) async {
    final String url = '/artists/$artistId/track-ids-by-rating';
    Map<String, dynamic> tracksJson = await _http.get(url);

    final trackIds = tracksJson['tracks'].join(',');
    final data = {'track-ids': trackIds, 'with-positions': 'True'};
    List<dynamic> json = await _http.postForm('/tracks', data: data);

    return json.map((track) => Track.fromJson(track, '')).toList();
  }

  Future<void> likeArtist(String artistId) async {
    final url = '/users/$uid/likes/artists/add';
    final data = {'artist-id': artistId};
    await _http.postForm(url, data: data);
  }

  Future<void> unlikeArtist(String artistId) async {
    final url = '/users/$uid/likes/artists/$artistId/remove';
    await _http.postForm(url);
  }

  Future<List<Tree>> landing3Metatags() async {
    List<Tree> trees = [];

    final data = await _http.get('/landing3/metatags');
    data['trees'].forEach((tree) => trees.add(Tree.fromJson(tree)));

    return trees;
  }

  Future<FeedPromotions> feedPromotions(String id) async {
    final data = await _http.get('/feed/promotions/$id');
    return FeedPromotions.fromJson(data);
  }

  Future<MetaTags> metaTags(String id) async {
    final data = await _http.get('/metatags/$id');
    return MetaTags.fromJson(data);
  }

  Future<Playlist> chart() async {
    final json = await _http.get('/landing3/chart');
    return Playlist.fromJson(json['chart']);
  }

  Future<List<Object>> searchHistory() async {
    final json = await _http.get('/landing-blocks/history');
    return json['items'].map((item) => getHistoryItem(item));
  }

  Future<String> getLyrics(String trackId, [LyricsFormat format = LyricsFormat.lrc]) async {
    final int ts = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
    final Uint8List key = utf8.encode(_newMagicSalt);
    final Uint8List data = utf8.encode('$trackId$ts');
    final Digest digest = Hmac(sha256, key).convert(data);
    final String sign = base64.encode(digest.bytes);
    final query = {'format': format.name.toUpperCase(), 'timeStamp': ts, 'sign': sign};

    Map<String, dynamic> json = await _http.get('/tracks/$trackId/lyrics',
        headers: {'X-Yandex-Music-Client': 'YandexMusicDesktopAppWindows/5.34.1'},
        queryParameters: query,
        cacheDuration: const Duration(days: 365));

    return await _http.get(json['downloadUrl'], cacheDuration: const Duration(days: 365));
  }

  Future<void> sendPlayInfo(PlayInfoBase playInfo) async {
    final data = {
      'plays': [playInfo.toJson()]
    };
    final clientDate = '${DateFormat('y-MM-ddTHH:mm:ss.S').format(playInfo.timestamp.toUtc())}Z';

    await _http.postJson('/plays?clientNow=${Uri.encodeQueryComponent(clientDate)}', data: data);
  }

  Future<List<Album>> newReleases() async {
    final json = await _http.get('/landing3/new-releases', cacheDuration: const Duration(days: 1));
    final albumIds = json['newReleases'];
    final albumsJson = await _http.postForm(
      '/albums',
      data: {
        'album-ids': albumIds.join(','),
      },
    );

    return albumsJson.map((item) => Album.fromJson(item));
  }

  Future<List<Playlist>> newPlaylists() async {
    final json = await _http.get('/landing3/new-playlists', cacheDuration: const Duration(days: 1));
    final playlistsIds = json['newPlaylists'];
    final playlistsJson = await _http.postForm(
      '/playlists/list',
      data: {
        'playlistIds': playlistsIds.map((i) => '${i['uid']}:${i['kind']}').join(','),
      },
    );

    return playlistsJson.map((item) => Playlist.fromJson(item));
  }

  Future<List<Genre>> genres() async {
    final List<dynamic> json = await _http.get('/genres');

    return json.map((item) => Genre.fromJson(item)).toList();
  }

  Future<void> plays(PlayInfoBase play) async {
    await _http.postJson(
      '/plays?clientNow=${Uri.encodeQueryComponent(play.timestamp.toUtcString())}',
      data: {
        'plays': [play.toJson()]
      },
    );
  }

  Future<void> sendRadioFeedback({
    required String sessionId,
    required RadioFeedback feedback,
  }) async {
    await _http.postJson(
      '/rotor/session/$sessionId/feedback/',
      data: feedback.toJson(),
    );
  }

  Future<RadioSession> startRadioSession(NewRadioSessionRequest session) async {
    Map<String, dynamic> json = await _http.postJson(
      '/rotor/session/new',
      data: session.toJson(),
    );

    return RadioSession.fromJson(json);
  }

  Future<RadioSession> cloneRadioSession(String sessionId, NewRadioSessionRequest session) async {
    Map<String, dynamic> json = await _http.postJson(
      '/rotor/session/$sessionId/clone',
      data: session.toJson(),
    );

    return RadioSession.fromJson(json);
  }

  Future<Iterable<Track>> loadRadioBatch({
    required String sessionId,
    required Iterable<RadioFeedback> feedbacks,
    required Iterable<String> queue,
  }) async {
    Map<String, dynamic> json = await _http.postJson(
      '/rotor/session/$sessionId/tracks',
      data: {
        'feedbacks': feedbacks.map((e) => e.toJson()).toList(),
        'queue': queue,
      },
    );

    final String batchId = json['batchId'];

    List<Track> tracks = [];
    for (final item in json['sequence']) {
      tracks.add(Track.fromJson(item, batchId));
    }

    return tracks;
  }

  Future<Playlist> createPlaylist(String title) async {
    final result = await _http.postForm(
      '/users/$uid/playlists/create',
      data: {
        'visibility': 'public',
        'title': title,
      },
    );
    final playlist = Playlist.fromJson(result);

    return playlist;
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await _http.postForm('/users/${playlist.uid}/playlists/${playlist.kind}/delete');
  }

  Future<TrackUploaderInfo> createPlaylistTracksLoader(Playlist playlist, String filename) async {
    final result = await _http.postForm('/loader/upload-url?uid=$uid'
        '&playlist-id=${playlist.kind}%3A${playlist.kind}&path=${Uri.encodeComponent(filename)}');

    return TrackUploaderInfo.fromJson(result);
  }

  Stream<double> uploadPlaylistTrack(Playlist playlist, String filepath) async* {
    yield 0;

    final String filename = basename(filepath);
    final TrackUploaderInfo uploaderInfo = await createPlaylistTracksLoader(playlist, filename);

    yield* _http.uploadFile(uploaderInfo.postTarget, filepath);
  }

  Future<Playlist> _playlistChangeRelative(
      int kind, List<Map<String, dynamic>> diff, int revision) async {
    final json = await _http.postForm(
      '/users/$uid/playlists/$kind/change-relative',
      data: {'diff': jsonEncode(diff), 'revision': revision},
    );

    return Playlist.fromJson(json);
  }

  Future<Playlist> insertPlaylistTracks(Playlist playlist, Iterable<Track> tracks,
      [int position = 0]) async {
    final diff = [
      {
        'op': 'insert',
        'at': position,
        'tracks': tracks.map((e) => {'id': e.id.toString(), 'albumId': e.firstAlbumId}).toList(),
      }
    ];

    return _playlistChangeRelative(playlist.kind, diff, playlist.revision!);
  }

  Future<Playlist> deletePlaylistTracks(Playlist playlist, Iterable<int> positions) async {
    final diff = positions
        .map((i) => {
              'op': 'delete',
              'from': i,
              'to': i + 1,
            })
        .toList();

    return _playlistChangeRelative(playlist.kind, diff, playlist.revision!);
  }

  Future<Playlist> movePlaylistTracks(
      Playlist playlist, Iterable<Track> tracks, int from, int to) async {
    final diff = [
      {
        'op': 'move',
        'from': from,
        'to': to,
        'tracks': tracks.map((e) => {'id': e.id.toString(), 'albumId': e.firstAlbumId}).toList(),
      }
    ];

    return _playlistChangeRelative(playlist.kind, diff, playlist.revision!);
  }

  Future<Playlist> changePlaylistTitle(Playlist playlist, String newTitle) async {
    final json = await _http.postForm(
      '/users/${playlist.uid}/playlists/${playlist.kind}/name',
      data: {'value': newTitle},
    );

    return Playlist.fromJson(json);
  }

  Future<void> likeAlbum(int albumId) async {
    final url = '/users/$uid/likes/albums/add';
    final data = {'album-id': albumId.toString()};

    await _http.postForm(url, data: data);
  }

  Future<void> unlikeAlbum(int albumId) async {
    final url = '/users/$uid/likes/albums/$albumId/remove';

    await _http.postForm(url);
  }
}
