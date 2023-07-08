import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:ya_player/models/music_api/account.dart';
import 'package:ya_player/models/music_api/artist.dart';

import 'models/music_api/album.dart';
import 'models/music_api/queue.dart';
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

  Future<Map<String, dynamic>> _getRequest(String uri, Map<String, String>? headers) async {
    Map<String, String> allHeaders = {
      if(_authToken != null) HttpHeaders.authorizationHeader: 'OAuth $_authToken',
      if(headers != null) ...headers
    };

    // debugPrint('Api request to: $uri');

    http.Response resp = await http.get(Uri.parse(uri), headers: allHeaders);

    Map<String, dynamic> json = {};

    if(resp.statusCode >= 200 && resp.statusCode < 400) {
      json = jsonDecode(resp.body);
    }

    // debugPrint('Api response body: ${resp.body}');

    return json;
  }

  Future<Map<String, dynamic>> _postJson(String uri, Map<String, String> data) async {
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
    Map<String, dynamic> json = await _getRequest('$_baseUri/rotor/stations/dashboard', null);
    return StationsDashboard.fromJson(json['result']);
  }

  Future<List<Track>> stationTacks(StationId stationId, List<int> queueTracks) async {
    String url = '$_baseUri/rotor/station/${stationId.type}:${stationId.tag}/tracks?settings2=true';
    if(queueTracks.isNotEmpty) {
      url += '&${queueTracks.join('%2C')}';
    }
    Map<String, dynamic> json = await _getRequest(url, null);
    List<Track> tracks = [];

    json['result']['sequence'].forEach((item){
      tracks.add(Track.fromJson(item, json['result']['batchId']));
    });

    return tracks;
  }

  Future<TrackDownloadInfo?> _trackDownloadInfo(int trackId) async {
    Map<String, dynamic> json = await _getRequest('$_baseUri/tracks/$trackId/download-info', null);
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
      Map<String, dynamic> json = await _getRequest('${info.downloadInfoUrl}&format=json', null);
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

  static Uri trackImageUrl(Track track, String imageDimensions) {
    return imageUrl(track.coverUri, imageDimensions);
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

  Future<List<int>> likedTracks({int revision = 0}) async {
    final url = '$_baseUri/users/$_uid/likes/tracks?if-modified-since-revision=$revision';
    Map<String, dynamic> json = await _getRequest(url, null);
    List<int> tracks = [];

    json['result']['library']['tracks'].forEach((item){
      tracks.add(int.parse(item['id']));
    });

    return tracks;
  }

  Future<List<Album>> likedAlbums() async {
    final url = '$_baseUri/users/$_uid/likes/albums?rich=true';
    Map<String, dynamic> json = await _getRequest(url, null);

    List<Album> albums = [];
    json['result'].forEach((item) => albums.add(Album.fromJson(item['album'])));

    return albums;
  }

  Future<List<Artist>> likedArtists() async {
    final url = '$_baseUri/users/$_uid/likes/artists?with-timestamps=true';
    Map<String, dynamic> json = await _getRequest(url, null);

    List<Artist> artists = [];
    json['result'].forEach((item) => artists.add(Artist.fromJson(item['artist'])));

    return artists;
  }

  Future<AccountStatus> accountStatus() async {
    const url = '$_baseUri/account/status';
    Map<String, dynamic> json = await _getRequest(url, null);

    Account? account;
    if(json['result']['account']['uid'] != null) {
      account = Account.fromJson(json['result']['account']);
    }

    return AccountStatus(account);
  }

  Future<String> createQueueForStation(Station station, List<QueueTrack> tracks) async {
    const url = '$_baseUri/queues';
    final from = station.id.type == 'user' ? station.id.tag : "${station.id.type}_${station.id.tag}";
    final queue = Queue(
      QueueContext(station.name, station.id),
      null, 'desktop_win-radio-radio_$from-default',
      false, tracks
    );
    final result = await _postJson(url, queue.toJons());

    return result['result']['id'].toString();
  }

  Future<void> updateQueuePosition(String queueId, int position) async {
    final url = '$_baseUri/queues/$queueId/update-position?currentIndex=$position&isInteractive=False';
    await _postEmpty(url);
  }
}
