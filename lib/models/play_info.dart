import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import 'music_api/playlist.dart';
import 'music_api/track.dart';

class PlayInfo {
  final Track track;
  final String from;
  var totalPlayed = const Duration();
  final String _uuid;

  PlayInfo(this.track, this.from) : _uuid = const Uuid().v4();

  Map<String, String> toYmPlayAudio() {
    final String dateTime = '${DateFormat('y-MM-ddTHH:mm:ss.S').format(DateTime.now().toUtc())}Z';
    final totalPlayedSeconds = (totalPlayed.inMilliseconds / 1000.0).toString();

    return {
      'track-id': track.id,
      'album-id': track.firstAlbumId.toString(),
      'from-cache': 'False',
      'from': from,
      'play-id': _uuid,
      'timestamp': dateTime,
      'client-now': dateTime,
      'track-length-seconds': (track.duration!.inMilliseconds / 1000.0).toString(),
      // предполагаю, что тут должно находиться количество секунд, которые
      // были проиграны. вот хороший пример:
      // началось проигрываниве, трек проигрался 5 секнуд, пользователь
      // решил пропустить/перемотать часть трека, к примеру 30 секунд,
      // пользователь прослушал еще 30 секунд трека и решил перейти к следующем
      // в этом случае 'total-played-seconds' = 35 секунд, а
      // 'end-position-seconds' = 65 секунд
      // значит 'total-played-seconds' — это фактическое время прослушивания трека,
      // 'end-position-seconds' — это позиция, на которой прослушивание завершилось
      'total-played-seconds': totalPlayedSeconds,
      'end-position-seconds': totalPlayedSeconds
    };
  }

  bool isTheSameAs(Track track, String from) {
    return from == this.from && track == this.track;
  }
}

enum PlayInfoContext { album, artist, playlist, radio }

abstract base class PlayInfoBase {
  final String albumId;
  final String audioAuto = 'none';
  final String audioOutputName = 'Динамик';
  final String audioOutputType = 'Speaker';
  final PlayInfoContext context;
  final String contextItem;
  final String from;
  bool fromCache = false;
  double endPositionSeconds;
  double totalPlayedSeconds;
  double trackLengthSeconds;
  bool pause;
  bool seek;
  final String playId;
  final String trackId;
  final DateTime timestamp;
  int? startTimestamp;
  String? maxPlayerStage;

  PlayInfoBase(
    Track track, {
    required this.albumId,
    required this.context,
    required this.contextItem,
    required this.from,
    this.endPositionSeconds = 0,
    this.totalPlayedSeconds = 0,
    this.trackLengthSeconds = 0,
    this.pause = false,
    this.seek = false,
    required this.trackId,
  })  : playId = const Uuid().v4(),
        timestamp = DateTime.now();

  Map<String, Object> _toMap() {
    final sinceEpoch = (timestamp.millisecondsSinceEpoch / 1000.0).round();
    final map = {
      'addTracksToPlayerTime': '${_generateRandomDigitString(18)}-$sinceEpoch',
      'albumId': albumId,
      'audioAuto': audioAuto,
      'audioOutputName': audioOutputName,
      'audioOutputType': audioOutputType,
      'context': context.name,
      'contextItem': contextItem,
      'fromCache': fromCache,
      'from': from,
      'endPositionSeconds': endPositionSeconds,
      'totalPlayedSeconds': totalPlayedSeconds,
      'trackLengthSeconds': trackLengthSeconds,
      'pause': pause,
      'seek': seek,
      'playId': playId,
      'trackId': trackId,
      'timestamp': '${DateFormat('y-MM-ddTHH:mm:ss.S').format(timestamp.toUtc())}Z'
    };

    if (startTimestamp != null) {
      map['startTimestamp'] = startTimestamp!;
    }

    if (maxPlayerStage != null) {
      map['maxPlayerStage'] = maxPlayerStage!;
    }

    return map;
  }

  Map<String, Object> toJson();

  String _generateRandomDigitString(int length) {
    final Random random = Random();
    return List<String>.generate(length, (_) => random.nextInt(10).toString()).join();
  }
}

final class PlayInfoRadio extends PlayInfoBase {
  final String radioSessionId;
  final bool isFromAutoflow = false;
  final String batchId;

  PlayInfoRadio(
    super.track, {
    required super.contextItem,
    required this.radioSessionId,
    required this.batchId,
  }) : super(
          context: PlayInfoContext.radio,
          from: 'desktop-home-rup_main-radio-default',
          trackId: track.id,
          albumId: track.firstAlbumId.toString(),
        );

  @override
  Map<String, Object> toJson() {
    final map = _toMap();
    map['radioSessionId'] = radioSessionId;
    map['isFromAutoflow'] = isFromAutoflow;
    map['batchId'] = batchId;

    return map;
  }
}

final class PlayInfoAlbum extends PlayInfoBase {
  PlayInfoAlbum(super.track)
      : super(
          context: PlayInfoContext.album,
          from: 'desktop-own_collection-collection_new_albums-default',
          contextItem: track.firstAlbumId.toString(),
          trackId: track.id,
          albumId: track.firstAlbumId.toString(),
        );

  @override
  Map<String, Object> toJson() {
    return _toMap();
  }
}

final class PlayInfoPlaylist extends PlayInfoBase {
  late final String playlistId;

  PlayInfoPlaylist(super.track, Playlist playlist)
      : super(
          context: PlayInfoContext.playlist,
          from: 'desktop-own_collection-collection_playlists-default',
          contextItem: '${playlist.uid}:${playlist.kind}',
          trackId: track.id,
          albumId: track.firstAlbumId.toString(),
        ) {
    playlistId = contextItem;
  }

  @override
  Map<String, Object> toJson() {
    final map = _toMap();
    map['playlistId'] = playlistId;

    return map;
  }
}

final class PlayInfoArtist extends PlayInfoBase {
  final bool isRestored = false;

  PlayInfoArtist(super.track)
      : super(
          context: PlayInfoContext.artist,
          from: 'desktop-own_collection-collection_artists-default',
          contextItem: track.artists.first.id.toString(),
          trackId: track.id,
          albumId: track.firstAlbumId.toString(),
        );

  @override
  Map<String, Object> toJson() {
    final map = _toMap();
    map['isRestored'] = isRestored;

    return map;
  }
}
