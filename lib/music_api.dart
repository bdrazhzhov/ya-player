import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:ya_player/models/music_api/account.dart';
import 'package:ya_player/models/music_api/artist.dart';
import 'package:ya_player/models/music_api/block.dart';
import 'package:ya_player/models/music_api/playlist.dart';
import 'package:collection/collection.dart';

import 'models/music_api/album.dart';
import 'models/music_api/artist_info.dart';
import 'models/music_api/non_music_catalog.dart';
import 'models/music_api/queue.dart';
import 'models/music_api/search.dart';
import 'models/music_api/station.dart';
import 'models/music_api/track.dart';
import 'models/music_api/download_info.dart';
import 'models/music_api/dashboard.dart';

class MusicApi {
  static const String _magicSalt = "XGRlBW9FXlekgbPrRHuSiA";
  static const String _baseUri = 'https://api.music.yandex.net';
  String? _authToken;
  int? _uid;

  set authToken(String value) { _authToken = value; }
  set uid(int value) { _uid = value; }

  MusicApi(String? authToken, int? uid) : _authToken = authToken, _uid = uid;

  Future<Map<String, dynamic>> _getRequest(String uri, { Map<String, String>? headers }) async {
    Map<String, String> allHeaders = {
      HttpHeaders.acceptLanguageHeader: 'en',
      if(_authToken != null) HttpHeaders.authorizationHeader: 'OAuth $_authToken',
      if(headers != null) ...headers
    };

    // debugPrint('Api request to: $uri');

    http.Response resp = await http.get(Uri.parse(uri), headers: allHeaders);

    Map<String, dynamic> json = {};

    if(resp.statusCode >= 200 && resp.statusCode < 400) {
      json = jsonDecode(resp.body);
    }
    else {
      debugPrint('Response error: ${resp.statusCode}');
      debugPrint(resp.body);
    }

    // debugPrint('Api response body: ${resp.body}');

    return json;
  }

  Future<Map<String, dynamic>> _postJson(String uri, Map<String, dynamic> data) async {
    // debugPrint('Api request to: $uri\nwith data: $data');
    http.Response resp = await http.post(Uri.parse(uri),
        headers: { HttpHeaders.authorizationHeader: 'OAuth $_authToken' },
        body: jsonEncode(data));
    // debugPrint('Api response body: ${resp.body}');

    Map<String, dynamic> json = {};

    if(resp.statusCode >= 200 && resp.statusCode < 400) {
      json = jsonDecode(resp.body);
    }

    return json;
  }

  Future<Map<String, dynamic>> _postForm(String uri, Map<String, dynamic> formData) async {
    // debugPrint('Api request to: $uri\nwith data: $formData');
    http.Response resp = await http.post(Uri.parse(uri),
        headers: { HttpHeaders.authorizationHeader: 'OAuth $_authToken' },
        body: formData);
    // debugPrint('Api response body: ${resp.body}');

    Map<String, dynamic> json = {};

    if(resp.statusCode >= 200 && resp.statusCode < 400) {
      json = jsonDecode(resp.body);
    }

    return json;
  }

  Future<Map<String, dynamic>> _postEmpty(String uri) async {
    // debugPrint('Api request to: $uri\nwith data: $formData');
    http.Response resp = await http.post(Uri.parse(uri),
        headers: { HttpHeaders.authorizationHeader: 'OAuth $_authToken' }
    );
    // debugPrint('Api response body: ${resp.body}');

    Map<String, dynamic> json = {};

    if(resp.statusCode >= 200 && resp.statusCode < 400) {
      json = jsonDecode(resp.body);
    }

    return json;
  }

  Future<StationsDashboard> stationsDashboard() async {
    Map<String, dynamic> json = await _getRequest('$_baseUri/rotor/stations/dashboard');
    return StationsDashboard.fromJson(json['result']);
  }

  Future<List<Station>> stationsList() async {
    Map<String, dynamic> json = await _getRequest('$_baseUri/rotor/stations/list');
    List<Station> stations = [];
    json['result'].forEach((item) => stations.add(Station.fromJson(item['station'])));

    return stations;
  }

  Future<List<Track>> stationTacks(StationId stationId, List<int> queueTracks) async {
    String url = '$_baseUri/rotor/station/${stationId.type}:${stationId.tag}/tracks?settings2=true';
    if(queueTracks.isNotEmpty) {
      url += '&${queueTracks.join('%2C')}';
    }
    Map<String, dynamic> json = await _getRequest(url);
    List<Track> tracks = [];

    json['result']['sequence'].forEach((item){
      tracks.add(Track.fromJson(item, json['result']['batchId']));
    });

    return tracks;
  }

  Future<TrackDownloadInfo?> _trackDownloadInfo(int trackId) async {
    Map<String, dynamic> json = await _getRequest('$_baseUri/tracks/$trackId/download-info');
    TrackDownloadInfo? selectedInfo;

    json['result'].forEach((item){
      final info = TrackDownloadInfo.fromJson(item);
      if(info.codec != 'mp3') return;

      if(selectedInfo == null || info.bitrateInKbps > selectedInfo!.bitrateInKbps)
      {
        selectedInfo = info;
      }
    });

    return selectedInfo;
  }

  Future<FileDownloadInfo?> _fileDownloadInfo(int trackId) async {
    FileDownloadInfo? fileInfo;

    TrackDownloadInfo? info = await _trackDownloadInfo(trackId);
    if(info != null) {
      Map<String, dynamic> json = await _getRequest('${info.downloadInfoUrl}&format=json');
      fileInfo = FileDownloadInfo.fromJson(json);
    }

    return fileInfo;
  }

  Future<String?> trackDownloadUrl(int trackId) async {
    String? downloadUrl;
    FileDownloadInfo? fileInfo = await _fileDownloadInfo(trackId);

    if(fileInfo != null) {
      final String token = _magicSalt + fileInfo.path.substring(1) + fileInfo.s;
      final String sign = md5.convert(utf8.encode(token)).toString();
      downloadUrl = 'https://${fileInfo.host}/get-mp3/$sign/${fileInfo.ts}${fileInfo.path}';
    }
    else {
      debugPrint('No download info for track $trackId');
    }

    return downloadUrl;
  }

  static Uri imageUrl(String placeholder, String dimensions) {
    return Uri.parse('https://${placeholder.replaceAll('%%', dimensions)}');
  }

  Future<void> sendStationTrackFeedback(StationId stationId, Track track,
      String feedbackType, Duration? totalPlayedSeconds) async {
    final data = {
      'type': feedbackType, // известны следующие значения: trackStarted, trackFinished, skip
      'timestamp': DateTime.now().toIso8601String(),
      'trackId': '${track.id}:${track.albums.first.id}'
    };
    if(totalPlayedSeconds != null && totalPlayedSeconds.inSeconds > 0) {
      data['totalPlayedSeconds'] = (totalPlayedSeconds.inMilliseconds / 1000.0).toString();
    }

    final url = '$_baseUri/rotor/station/${stationId.type}:'
        '${stationId.tag}/feedback?batch-id=${track.batchId}';

    await _postJson(url, data);
  }

  Future<void> sendPlayingStatistics(Map<String, String> playInfo) async {
    playInfo['uid'] = _uid.toString();
    await _postForm('$_baseUri/play-audio', playInfo);
  }

  Future<void> likeTrack(Track track) async {
    final url = '$_baseUri/users/$_uid/likes/tracks/add-multiple';
    final data = {'track-ids': '${track.id}:${track.albums.first.id}'};
    await _postForm(url, data);
  }

  Future<void> unlikeTrack(Track track) async {
    final url = '$_baseUri/users/$_uid/likes/tracks/remove';
    final data = {'track-ids': '${track.id}:${track.albums.first.id}'};
    await _postForm(url, data);
  }

  Future<({List<int> ids, int? revision})> likedTrackIds({int revision = 0}) async {
    final url = '$_baseUri/users/$_uid/likes/tracks?if-modified-since-revision=$revision';
    Map<String, dynamic> json = await _getRequest(url);
    List<int> ids = [];

    int? newRevision;
    if(json['result'] != 'no-updates') {
      newRevision = json['result']['library']['revision'];
      json['result']['library']['tracks'].forEach((item){
        ids.add(int.parse(item['id']));
      });
    }

    return (ids: ids, revision: newRevision);
  }

  Future<List<Track>> likedTracks(List<int> ids) async {
    const url = '$_baseUri/tracks';
    final data = {'track-ids': ids.join(','), 'with-positions': 'True'};
    Map<String, dynamic> json = await _postForm(url, data);
    List<Track> tracks = [];
    json['result'].forEach((item){
      tracks.add(Track.fromJson(item, ''));
    });

    return tracks;
  }

  Future<List<Track>> tracks(List<TrackOfList> ids) async {
    final String trackIds = ids.map((e) => '${e.id}:${e.albumId}').join(',');
    const url = '$_baseUri/tracks';
    final data = {
      'track-ids': trackIds,
      'with-positions': 'True'
    };
    Map<String, dynamic> json = await _postForm(url, data);
    List<Track> tracks = [];
    json['result'].forEach((item){
      tracks.add(Track.fromJson(item, ''));
    });

    return tracks;
  }

  Future<List<Album>> likedAlbums() async {
    final url = '$_baseUri/users/$_uid/likes/albums?rich=true';
    Map<String, dynamic> json = await _getRequest(url);

    List<Album> albums = [];
    json['result'].forEach((item) => albums.add(Album.fromJson(item['album'])));

    return albums;
  }

  Future<List<LikedArtist>> likedArtists() async {
    final url = '$_baseUri/users/$_uid/likes/artists?with-timestamps=true';
    Map<String, dynamic> json = await _getRequest(url);

    List<LikedArtist> artists = [];
    json['result'].forEach((item) => artists.add(LikedArtist.fromJson(item['artist'])));

    return artists;
  }

  Future<List<Playlist>> playlistsWithTracks() async {
    List<int> kinds = await _playlistKinds();
    final url = '$_baseUri/users/$_uid/playlists';
    Map<String, dynamic> json = await _postForm(url, {'kinds': kinds.join(',')});

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
    final url = '$_baseUri/users/$_uid/playlists/list';
    Map<String, dynamic> json = await _getRequest(url);

    final List<Playlist> playlists = [];
    json['result'].forEach((item) {
      playlists.add(Playlist.fromJson(item));
    });

    return playlists;
  }

  Future<List<int>> _playlistKinds() async {
    final url = '$_baseUri/users/$_uid/playlists/list';
    Map<String, dynamic> json = await _getRequest(url);

    List<int> kinds = [];
    json['result'].forEach((item) => kinds.add(item['kind']));

    return kinds;
  }

  Future<AccountStatus> accountStatus() async {
    const url = '$_baseUri/account/status';
    Map<String, dynamic> json = await _getRequest(url);

    Account? account;
    if(json['result']['account']['uid'] != null) {
      account = Account.fromJson(json['result']['account']);
    }

    return AccountStatus(account);
  }

  Future<String> _createQueue(Queue queue) async {
    const url = '$_baseUri/queues';
    final result = await _postJson(url, queue.toMap());

    return result['result']['id'].toString();
  }

  Future<String> createQueueForStation(Station station, List<QueueTrack> tracks) {
    final from = station.id.type == 'user' ? station.id.tag : "${station.id.type}_${station.id.tag}";
    final queue = Queue(
      context: QueueContext(
        description: station.name,
        id: '${station.id.type}:${station.id.tag}',
        type: 'radio'
      ),
      currentIndex: null,
      from: 'desktop_win-radio-radio_$from-default',
      isInteractive: false,
      tracks: tracks
    );

    return _createQueue(queue);
  }

  Future<String> createQueueForLikedTracks(List<QueueTrack> tracks, int currentIndex) {
    final queue = Queue(
        context: QueueContext(
          description: '',
          id: 'fonoteca',
          type: 'radio'
        ),
        currentIndex: currentIndex,
        isInteractive: true,
        tracks: tracks
    );

    return _createQueue(queue);
  }

  Future<void> updateQueuePosition(String queueId, int position) async {
    final url = '$_baseUri/queues/$queueId/update-position?currentIndex=$position&isInteractive=False';
    await _postEmpty(url);
  }

  Future<AlbumWithTracks> albumWithTracks(int albumId) async {
    final url = '$_baseUri/albums/$albumId/with-tracks';
    Map<String, dynamic> json = await _getRequest(url);
    final result = AlbumWithTracks.fromJson(json);

    return result;
  }

  Future<ArtistInfo> artistInfo(int artistId) async {
    final url = '$_baseUri/artists/$artistId/brief-info';
    Map<String, dynamic> json = await _getRequest(url);
    final result = ArtistInfo.fromJson(json);

    return result;
  }

  Future<SearchSuggestions> searchSuggestions(String text) async {
    final url = '$_baseUri/search/suggest?part=$text';
    Map<String, dynamic> json = await _getRequest(url);
    final result = SearchSuggestions.fromJson(json);

    return result;
  }

  Future<SearchResult> searchResult({required String text, String type = 'all', int page = 0}) async {
    final url = '$_baseUri/search?text=${Uri.encodeComponent(text)}'
        '&nocorrect=false&type=$type&page=$page&playlist-in-best=true';
    Map<String, dynamic> json = await _getRequest(url);

    return SearchResult.fromJson(json);
  }

  Future<NonMusicCatalog> nonMusicCatalog() async {
    const url = '$_baseUri/non-music/catalogue';
    Map<String, dynamic> json = await _getRequest(url);

    return NonMusicCatalog.fromJson(json['result']);
  }

  Future<List<Block>> landing() async {
    const url = '$_baseUri/landing3?blocks=personalplaylists,promotions,new-releases,'
        'new-playlists,mixes,chart,charts,artists,albums,playlists,play_contexts,podcasts';
    Map<String, dynamic> json = await _getRequest(url);
    List<Block> blocks = [];

    json['result']['blocks'].forEach((blockJson) => blocks.add(Block.fromJson(blockJson)));

    return blocks;
  }

  Future<Playlist> playlist(int uid, int kind) async {
    final String url = '$_baseUri/users/$uid/playlists/$kind';
    Map<String, dynamic> json = await _getRequest(url);

    return Playlist.fromJson(json['result']);
  }
}
