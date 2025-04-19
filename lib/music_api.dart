import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import '/models/music_api/can_be_played.dart';
import 'helpers/paged_data.dart';
import 'models/music_api/history.dart';
import 'models/music_api_types.dart';
import 'models/play_info.dart';
import 'services/service_locator.dart';
import 'services/yandex_api_client.dart';

enum AlbumsSortBy { rating, year }
enum AlbumsSortOrder { desc, asc }
enum LyricsFormat { lrc, text }

final class QueueIndexInvalid implements Exception {}

class MusicApi {
  static const String _newMagicSalt = 'kzqU4XhfCaY6B6JTHODeq5';
  int uid;
  late final YandexApiClient _http;

  MusicApi(this.uid)
  {
    _http = getIt<YandexApiClient>();
  }

  Future<StationsDashboard> stationsDashboard() async {
    Map<String, dynamic> json = await _http.get('/rotor/stations/dashboard');
    return StationsDashboard.fromJson(json['result']);
  }

  Future<List<Station>> stationsList() async {
    Map<String, dynamic> json = await _http.get('/rotor/stations/list');
    List<Station> stations = [];
    json['result'].forEach((item) => stations.add(Station.fromJson(item['station'], item['settings2'])));

    return stations;
  }

  Future<Iterable<Track>> stationTacks(StationId stationId, Iterable<String> queueTracks) async {
    String url = '/rotor/station/${stationId.type}:${stationId.tag}/tracks?settings2=true';
    if(queueTracks.isNotEmpty) {
      url += '&queue=${queueTracks.join('%2C')}';
    }
    Map<String, dynamic> json = await _http.get(url);
    List<Track> tracks = [];

    json['result']['sequence'].forEach((item){
      tracks.add(Track.fromJson(item, json['result']['batchId']));
    });

    return tracks;
  }

  Future<Station> station(StationId stationId) async {
    final url = '/rotor/station/${stationId.type}:${stationId.tag}/info';
    Map<String, dynamic> json = await _http.get(url);

    return Station.fromJson(
      json['result'].first['station'],
      json['result'].first['settings2']
    );
  }

  Future<void> updateStationSettings2(StationId stationId, Map<String,String> settings2) async {
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

    Map<String, dynamic> json = await _http.get(
      '/get-file-info',
      headers: {'X-Yandex-Music-Client': 'YandexMusicDesktopAppWindows/5.34.1'},
      queryParameters: query
    );

    String? encryptionKey;
    if(json['result']['downloadInfo']['key'] != null) {
      encryptionKey = json['result']['downloadInfo']['key'].toString();
    }
    return UrlData(
      url: json['result']['downloadInfo']['url'].toString(),
      encryptionKey: encryptionKey
    );
  }

  static String imageUrl(String placeholder, String dimensions) {
    return 'https://${placeholder.replaceAll('%%', dimensions)}';
  }

  Future<void> sendStationTrackFeedback(StationId stationId, CanBePlayed? track,
      String feedbackType, Duration? totalPlayedSeconds) async {
    final data = {
      'type': feedbackType, // известны следующие значения: radioStarted, trackStarted, trackFinished, skip, like, unlike
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    String url = '/rotor/station/${stationId.type}:${stationId.tag}/feedback';

    if(track != null) {
      data['trackId'] = track.fullId;
      if(track is Track) {
        url += '?batch-id=${track.batchId}';
      }
    }

    if(totalPlayedSeconds != null && totalPlayedSeconds.inSeconds > 0) {
      data['totalPlayedSeconds'] = (totalPlayedSeconds.inMilliseconds / 1000.0).toString();
    }

    await _http.postJson(url, data: data);
  }

  Future<void> sendPlayingStatistics(Map<String, String> playInfo) async {
    playInfo['uid'] = uid.toString();
    await _http.postForm('/play-audio', data: playInfo);
  }

  Future<void> likeTrack(CanBePlayed track) async {
    final url = '/users/$uid/likes/tracks/add-multiple';
    final data = {'track-ids': track.fullId};
    await _http.postForm(url, data: data);
  }

  Future<void> unlikeTrack(CanBePlayed track) async {
    final data = {'track-ids': track.fullId};
    await _http.postForm('/users/$uid/likes/tracks/remove', data: data);
  }

  Future<({List<String> ids, int? revision})> likedTrackIds({int revision = 0}) async {
    final url = '/users/$uid/likes/tracks?if-modified-since-revision=$revision';
    Map<String, dynamic> json = await _http.get(url);
    List<String> ids = [];

    int? newRevision;
    if(json['result'] != 'no-updates') {
      newRevision = json['result']['library']['revision'];
      json['result']['library']['tracks'].forEach((item){
        ids.add(item['id']);
      });
    }

    return (ids: ids, revision: newRevision);
  }

  Future<List<Track>> tracksByIds(List<String> ids) async {
    final data = {'track-ids': ids.join(','), 'with-positions': 'True'};
    Map<String, dynamic> json = await _http.postForm('/tracks', data: data);
    List<Track> tracks = [];
    json['result'].forEach((item){
      final track = Track.fromJson(item, '');
      if(track.albums.isEmpty) return;

      tracks.add(track);
    });

    return tracks;
  }

  Future<List<Track>> tracks(Iterable<TrackOfList> ids) async {
    final String trackIds = ids.map((e) => '${e.id}:${e.albumId}').join(',');
    final data = {
      'track-ids': trackIds,
      'with-positions': 'True'
    };
    Map<String, dynamic> json = await _http.postForm('/tracks', data: data);
    List<Track> tracks = [];
    json['result'].forEach((item){
      tracks.add(Track.fromJson(item, ''));
    });

    return tracks;
  }

  Future<List<Album>> likedAlbums() async {
    Map<String, dynamic> json = await _http.get('/users/$uid/likes/albums?rich=true');

    List<Album> albums = [];
    json['result'].forEach((item) => albums.add(Album.fromJson(item['album'])));

    return albums;
  }

  Future<List<Artist>> likedArtists() async {
    Map<String, dynamic> json = await _http.get('/users/$uid/likes/artists?with-timestamps=true');

    List<Artist> artists = [];
    json['result'].forEach((item) => artists.add(Artist.fromJson(item['artist'])));

    return artists;
  }

  Future<List<Playlist>> playlistsWithTracks() async {
    List<int> kinds = await _playlistKinds();
    Map<String, dynamic> json = await _http.postForm(
      '/users/$uid/playlists',
      data: {'kinds': kinds.join(',')}
    );

    final List<Playlist> playlists = [];
    json['result'].forEach((item) {
      playlists.add(Playlist.fromJson(item));
    });

    // final List<TrackOfList> trackIds = [];
    // for (Playlist playlist in playlists) {
    //   for (TrackOfList trackOfList in playlist.trackOfLists) {
    //     trackIds.add(trackOfList);
    //   }
    // }
    //
    // List<Track> allTracks = await tracks(trackIds);
    // for (Playlist playlist in playlists) {
    //   for (TrackOfList trackOfList in playlist.trackOfLists) {
    //     Track? track = allTracks.firstWhereOrNull(
    //             (element) => element.id == trackOfList.id &&
    //                 element.albums.firstOrNull?.id == trackOfList.albumId
    //     );
    //     if(track == null) continue;
    //     playlist.tracks.add(track);
    //   }
    // }

    return playlists;
  }

  Future<List<Playlist>> playlists() async {
    Map<String, dynamic> json = await _http.get('/users/$uid/playlists/list');

    final List<Playlist> playlists = [];
    json['result'].forEach((item) {
      playlists.add(Playlist.fromJson(item));
    });

    return playlists;
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
    final String queueId = result['result']['id'].toString();

    return Queue(
      id: queueId,
      context: context,
      tracks: tracks,
      currentIndex: currentIndex,
      isInteractive: isInteractive,
      from: from
    );
  }

  Future<List<int>> _playlistKinds() async {
    Map<String, dynamic> json = await _http.get('/users/$uid/playlists/list');

    List<int> kinds = [];
    json['result'].forEach((item) => kinds.add(item['kind']));

    return kinds;
  }

  Future<AccountStatus> accountStatus() async {
    Map<String, dynamic> json = await _http.get('/account/status');

    Account? account;
    if(json['result']['account']['uid'] != null) {
      account = Account.fromJson(json['result']['account']);
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
      if(e.response == null) rethrow;

      final resp = e.response!;
      if(resp.statusCode == 400 && resp.data['result']['message'] == 'currentIndex is invalid') {
        throw QueueIndexInvalid();
      }
      else {
        rethrow;
      }
    }
  }

  Future<Queue> createQueueForStation(Station station, List<QueueTrack> tracks) {
    final from = station.id.type == 'user' ? station.id.tag : "${station.id.type}_${station.id.tag}";
    final context = QueueContext(
      description: station.name,
      id: '${station.id.type}:${station.id.tag}',
      type: 'radio'
    );

    // return createQueue(queue);
    return createQueue(context: context,
      currentIndex: null,
      from: 'desktop_win-radio-radio_$from-default',
      isInteractive: false,
      tracks: tracks
    );
  }

  Future<Queue> createQueueForLikedTracks(List<QueueTrack> tracks, int currentIndex) {
    const context = QueueContext(
        description: '',
        id: 'fonoteca',
        type: 'my_music'
    );

    return createQueue(
      context: context,
      currentIndex: currentIndex,
      isInteractive: true,
      tracks: tracks
    );
  }

  Future<Queue> createQueueForAlbum(Album album, List<QueueTrack> tracks, int currentIndex) {
    return createQueue(
        context: QueueContext(
            description: album.title,
            id: album.id.toString(),
            type: 'album'
        ),
        currentIndex: currentIndex,
        isInteractive: true,
        tracks: tracks
    );
  }

  Future<Queue> createQueueForPlaylist(Playlist playlist, List<QueueTrack> tracks, int currentIndex) {
    return createQueue(
      context: QueueContext(
          description: playlist.title,
          id: '${playlist.uid}:${playlist.kind}',
          type: 'my_music'
      ),
      currentIndex: currentIndex,
      isInteractive: true,
      tracks: tracks
    );
  }

  Future<AlbumWithTracks> albumWithTracks(int albumId) async {
    Map<String, dynamic> json = await _http.get('/albums/$albumId/with-tracks');
    final result = AlbumWithTracks.fromJson(json);

    return result;
  }

  Future<ArtistInfo> artistInfo(int artistId) async {
    Map<String, dynamic> json = await _http.get('/artists/$artistId/brief-info');
    final result = ArtistInfo.fromJson(json);

    return result;
  }

  Future<SearchSuggestions> searchSuggestions(String text) async {
    Map<String, dynamic> json = await _http.get('/search/suggest?part=$text');
    final result = SearchSuggestions.fromJson(json);

    return result;
  }

  Future<SearchResult> searchResult({required String text, String type = 'all', int page = 0}) async {
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
      'withLikesCount': true
    };
    if(filter != null) {
      query['filter'] = filter.name;
    }
    Map<String, dynamic> json = await _http.get('/search/instant/mixed',
      queryParameters: query,
      cacheDuration: const Duration(minutes: 5)
    );

    List<Object> items = [];
    if(json['result']['results'] != null) {
      json['result']['results'].forEach((item) {
        final Object? result = createSearchResultEntry(item);
        if(result == null) return;

        items.add(result);
      });
    }

    return SearchResultMixed(
      page: 0,
      perPage: 36,
      total: json['result']['total'],
      filter: filter,
      items: items
    );
  }

  static const List<String> skippedBlockIds = ['CONTINUE_LISTEN',
    'nonmusic-menu-tab', 'bookmate_banner'];

  Future<List<Block>> nonMusicCatalog() async {
    Map<String, dynamic> json = await _http.get('/non-music/catalogue');
    List<Block> blocks = [];

    json['result']['blocks'].forEach((blockJson) {
      if(skippedBlockIds.contains(blockJson['id'])) return;

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

    json['result']['blocks'].forEach((blockJson) {
      if(blockJson['type'] == 'charts') return;

      blocks.add(Block.fromJson(blockJson));
    });

    return blocks;
  }

  Future<Playlist> playlist(int uid, int kind) async {
    Map<String, dynamic> json = await _http.get('/users/$uid/playlists/$kind');

    return Playlist.fromJson(json['result']);
  }

  Future<List<String>> queueIds() async {
    Map<String, dynamic> json = await _http.get('/queues');
    List<String> queues = [];

    json['result']['queues'].forEach((q) => queues.add(q['id']));

    return queues;
  }

  Future<Queue> queue(String id) async {
    Map<String, dynamic> json = await _http.get('/queues/$id');

    return Queue.fromJson(json['result']);
  }

  Future<List<String>> trackIdsByRating(int artistId) async {
    Map<String, dynamic> json = await _http.get('/artists/$artistId/track-ids-by-rating');

    return json['result']['tracks'];
  }

  Future<PagedData<Album>> artistAlbums({
    required int artistId, page = 0, perPage = 50,
    AlbumsSortBy sortBy = AlbumsSortBy.rating,
    AlbumsSortOrder sortOrder = AlbumsSortOrder.desc
  }) async {
    final sortByString = sortBy.toString().split('.').last;
    final sortOrderString = sortOrder.toString().split('.').last;
    final String url = '/artists/$artistId/direct-albums?page=$page'
        '&page-size=$perPage&sort-by=$sortByString&sort-order=$sortOrderString';
    Map<String, dynamic> json = await _http.get(url);
    List<Album> albums = [];
    json['result']['albums'].forEach((a) => albums.add(Album.fromJson(a)));

    return PagedData.fromJson(json['result']['pager'], albums);
  }

  Future<PagedData<Album>> artistAlsoAlbums({
    required int artistId, page = 0, perPage = 50
  }) async {
    final String url = '/artists/$artistId/also-albums?page=$page&page-size=$perPage';
    Map<String, dynamic> json = await _http.get(url);
    List<Album> albums = [];
    json['result']['albums'].forEach((a) => albums.add(Album.fromJson(a)));

    return PagedData.fromJson(json['result']['pager'], albums);
  }
  
  Future<List<Track>> artistPopularTracks(int artistId) async {
    final String url = '/artists/$artistId/track-ids-by-rating';
    Map<String, dynamic> json = await _http.get(url);

    final trackIds = json['result']['tracks'].join(',');
    final data = {
      'track-ids': trackIds,
      'with-positions': 'True'
    };
    json = await _http.postForm('/tracks', data: data);

    List<Track> tracks = [];
    json['result'].forEach((track) => tracks.add(Track.fromJson(track, '')));

    return tracks;
  }

  Future<void> likeArtist(int artistId) async {
    final url = '/users/$uid/likes/artists/add';
    final data = {'artist-id': '$artistId'};
    await _http.postForm(url, data: data);
  }

  Future<void> unlikeArtist(int artistId) async {
    final url = '/users/$uid/likes/artists/$artistId/remove';
    await _http.postForm(url);
  }

  Future<List<Tree>> landing3Metatags() async {
    List<Tree> trees = [];

    final data = await _http.get('/landing3/metatags');
    data['result']['trees'].forEach((tree) => trees.add(Tree.fromJson(tree)));

    return trees;
  }

  Future<FeedPromotions> feedPromotions(String id) async {
    final data = await _http.get('/feed/promotions/$id');
    return FeedPromotions.fromJson(data['result']);
  }

  Future<MetaTags> metaTags(String id) async {
    final data = await _http.get('/metatags/$id');
    return MetaTags.fromJson(data['result']);
  }

  Future<Playlist> chart() async {
    final json = await _http.get('/landing3/chart');
    return Playlist.fromJson(json['result']['chart']);
  }

  Future<List<Object>> history() async {
    List<Object> history = [];

    final json = await _http.get('/landing-blocks/history');

    json['result']['items'].forEach((item) => history.add(getHistoryItem(item)));

    return history;
  }

  Future<String> getLyrics(String trackId, [LyricsFormat format = LyricsFormat.lrc]) async {
    final int ts = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
    final Uint8List key = utf8.encode(_newMagicSalt);
    final Uint8List data = utf8.encode('$trackId$ts');
    final Digest digest = Hmac(sha256, key).convert(data);
    final String sign = base64.encode(digest.bytes);
    final query = {
      'format': format.name.toUpperCase(),
      'timeStamp': ts,
      'sign': sign
    };

    Map<String, dynamic> json = await _http.get(
      '/tracks/$trackId/lyrics',
      headers: { 'X-Yandex-Music-Client': 'YandexMusicDesktopAppWindows/5.34.1' },
      queryParameters: query,
      cacheDuration: const Duration(days: 365)
    );

    return await _http.get(
      json['result']['downloadUrl'],
      cacheDuration: const Duration(days: 365)
    );
  }

  Future<void> sendPlayInfo(PlayInfoBase playInfo) async {
    final data = { 'plays': [playInfo.toJson()] };
    final clientDate = '${DateFormat('y-MM-ddTHH:mm:ss.S').format(playInfo.timestamp.toUtc())}Z';

    await _http.postJson('/plays?clientNow=${Uri.encodeQueryComponent(clientDate)}', data: data);
  }

  Future<List<Album>> newReleases() async {
    final json = await _http.get('/landing3/new-releases', cacheDuration: const Duration(days: 1));
    final albumIds = json['result']['newReleases'];
    final albumsJson = await _http.postForm(
      '/albums',
      data: {
        'album-ids': albumIds.join(','),
      },
    );
    List<Album> albums = [];
    albumsJson['result'].forEach((item) {
      final album = Album.fromJson(item);
      albums.add(album);
    });

    return albums;
  }

  Future<List<Playlist>> newPlaylists() async {
    final json = await _http.get('/landing3/new-playlists', cacheDuration: const Duration(days: 1));
    final playlistsIds = json['result']['newPlaylists'];
    final playlistsJson = await _http.postForm(
      '/playlists/list',
      data: {
        'playlistIds': playlistsIds.map((i) => '${i['uid']}:${i['kind']}').join(','),
      },
    );
    List<Playlist> playlists = [];
    playlistsJson['result'].forEach((item) {
      final playlist = Playlist.fromJson(item);
      playlists.add(playlist);
    });

    return playlists;
  }
}
