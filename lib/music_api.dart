import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'helpers/paged_data.dart';
import 'models/music_api_types.dart';
import 'services/service_locator.dart';
import 'services/yandex_api_client.dart';

class MusicApi {
  static const String _magicSalt = "XGRlBW9FXlekgbPrRHuSiA";
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
    json['result'].forEach((item) => stations.add(Station.fromJson(item['station'])));

    return stations;
  }

  Future<List<Track>> stationTacks(StationId stationId, List<int> queueTracks) async {
    String url = '/rotor/station/${stationId.type}:${stationId.tag}/tracks?settings2=true';
    if(queueTracks.isNotEmpty) {
      url += '&${queueTracks.join('%2C')}';
    }
    Map<String, dynamic> json = await _http.get(url);
    List<Track> tracks = [];

    json['result']['sequence'].forEach((item){
      tracks.add(Track.fromJson(item, json['result']['batchId']));
    });

    return tracks;
  }

  Future<TrackDownloadInfo?> _trackDownloadInfo(int trackId) async {
    Map<String, dynamic> json = await _http.get('/tracks/$trackId/download-info');
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
      Map<String, dynamic> json = await _http.get('${info.downloadInfoUrl}&format=json');
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

  static String imageUrl(String placeholder, String dimensions) {
    return 'https://${placeholder.replaceAll('%%', dimensions)}';
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

    final url = '/rotor/station/${stationId.type}:'
        '${stationId.tag}/feedback?batch-id=${track.batchId}';

    await _http.postJson(url, data: data);
  }

  Future<void> sendPlayingStatistics(Map<String, String> playInfo) async {
    playInfo['uid'] = uid.toString();
    await _http.postForm('/play-audio', data: playInfo);
  }

  Future<void> likeTrack(Track track) async {
    final url = '/users/$uid/likes/tracks/add-multiple';
    final data = {'track-ids': '${track.id}:${track.albums.first.id}'};
    await _http.postForm(url, data: data);
  }

  Future<void> unlikeTrack(Track track) async {
    final data = {'track-ids': '${track.id}:${track.albums.first.id}'};
    await _http.postForm('/users/$uid/likes/tracks/remove', data: data);
  }

  Future<({List<int> ids, int? revision})> likedTrackIds({int revision = 0}) async {
    final url = '/users/$uid/likes/tracks?if-modified-since-revision=$revision';
    Map<String, dynamic> json = await _http.get(url);
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

  Future<List<Track>> tracksByIds(List<int> ids) async {
    final data = {'track-ids': ids.join(','), 'with-positions': 'True'};
    Map<String, dynamic> json = await _http.postForm('/tracks', data: data);
    List<Track> tracks = [];
    json['result'].forEach((item){
      tracks.add(Track.fromJson(item, ''));
    });

    return tracks;
  }

  Future<List<Track>> tracks(List<TrackOfList> ids) async {
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

  Future<List<LikedArtist>> likedArtists() async {
    Map<String, dynamic> json = await _http.get('/users/$uid/likes/artists?with-timestamps=true');

    List<LikedArtist> artists = [];
    json['result'].forEach((item) => artists.add(LikedArtist.fromJson(item['artist'])));

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

  Future<String> _createQueue(Queue queue) async {
    final result = await _http.postJson('/queues', data: queue.toMap());

    return result['result']['id'].toString();
  }

  Future<void> updateQueuePosition(String queueId, int position) async {
    final url = '/queues/$queueId/update-position?currentIndex=$position&isInteractive=False';
    await _http.postForm(url);
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
          type: 'my_music'
        ),
        currentIndex: currentIndex,
        isInteractive: true,
        tracks: tracks
    );

    return _createQueue(queue);
  }

  Future<String> createQueueForAlbum(Album album, List<QueueTrack> tracks, int currentIndex) {
    final queue = Queue(
        context: QueueContext(
          description: album.title,
          id: album.id.toString(),
          type: 'album'
        ),
        currentIndex: currentIndex,
        isInteractive: true,
        tracks: tracks
    );

    return _createQueue(queue);
  }

  Future<String> createQueueForPlaylist(Playlist playlist, List<QueueTrack> tracks, int currentIndex) {
    final queue = Queue(
        context: QueueContext(
            description: playlist.title,
            id: '${playlist.uid}:${playlist.kind}',
            type: 'my_music'
        ),
        currentIndex: currentIndex,
        isInteractive: true,
        tracks: tracks
    );

    return _createQueue(queue);
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
        'new-playlists,mixes,chart,charts,artists,albums,playlists,play_contexts,podcasts';
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

  Future<List<Queue>> queues() async {
    Map<String, dynamic> json = await _http.get('/queues');
    List<Queue> queues = [];

    json['result']['queues'].forEach((q) => Queue.fromJson(q));

    return queues;
  }

  Future<List<int>> trackIdsByRating(int artistId) async {
    Map<String, dynamic> json = await _http.get('/artists/$artistId/track-ids-by-rating');
    final List<int> ids = [];
    json['result']['tracks'].forEach((t) => ids.add(int.parse(t)));

    return ids;
  }

  Future<PagedData<Album>> artistAlbums(int artistId) async {
    final String url = '/artists/$artistId/direct-albums?page=0&page-size=50&sort-by=rating&sort-order=desc';
    Map<String, dynamic> json = await _http.get(url);
    List<Album> albums = [];
    json['result']['albums'].forEach((a) => albums.add(Album.fromJson(a)));

    return PagedData.fromJson(json['pager'], albums);
  }
}
