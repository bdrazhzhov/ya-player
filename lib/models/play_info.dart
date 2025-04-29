import 'dart:math';

import 'package:uuid/uuid.dart';

import '/helpers/date_extensions.dart';
import 'music_api/playlist.dart';
import 'music_api/radio_session.dart';
import 'music_api/track.dart';

enum PlayInfoContext {
  various, album, artist, playlist, radio;

  factory PlayInfoContext.fromString(String stringValue) {
    for (PlayInfoContext value in values) {
      if (value.name.toUpperCase() == stringValue) {
        return value;
      }
    }

    throw ArgumentError('Unknown PlayInfoContext type: $stringValue');
  }

  @override
  String toString() {
    return name.toUpperCase();
  }
}

abstract base class PlayInfoBase {
  final String albumId;
  final String audioAuto = 'none';
  final String audioOutputName = 'Динамик';
  final String audioOutputType = 'Speaker';
  final PlayInfoContext context;
  final String contextItem;
  final String from;
  bool fromCache = false;
  Duration endPosition;
  Duration totalPlayed;
  Duration trackLength;
  bool pause;
  bool seek;
  final String playId;
  final String trackId;
  final DateTime timestamp;
  int? startTimestamp;
  String? maxPlayerStage;
  bool? isRestored;

  PlayInfoBase(
    Track track, {
    required this.context,
    required this.contextItem,
    required this.from,
    this.endPosition = Duration.zero,
    this.totalPlayed = Duration.zero,
    this.pause = false,
    this.seek = false,
    this.isRestored,
  })  : playId = const Uuid().v4(),
        timestamp = DateTime.now(),
        trackLength = track.duration!,
        trackId = track.id,
        albumId = track.firstAlbumId.toString();

  Map<String, Object> toJson() {
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
      'endPositionSeconds': endPosition.inMilliseconds / 1000.0,
      'totalPlayedSeconds': totalPlayed.inMilliseconds / 1000.0,
      'trackLengthSeconds': trackLength.inMilliseconds / 1000.0,
      'pause': pause,
      'seek': seek,
      'playId': playId,
      'trackId': trackId,
      'timestamp': timestamp.toUtcString(),
    };

    if (startTimestamp != null) {
      map['startTimestamp'] = startTimestamp!;
    }

    if (maxPlayerStage != null) {
      map['maxPlayerStage'] = maxPlayerStage!;
    }

    if (isRestored != null) {
      map['isRestored'] = isRestored!;
    }

    return map;
  }

  String _generateRandomDigitString(int length) {
    final Random random = Random();
    return List<String>.generate(length, (_) => random.nextInt(10).toString()).join();
  }
}

final class PlayInfoRadio extends PlayInfoBase {
  final bool isFromAutoflow = false;
  final RadioSession session;

  static const String defaultFrom = 'desktop-home-rup_main-radio-default';

  PlayInfoRadio(super.track, this.session)
      : super(
          context: PlayInfoContext.radio,
          from: defaultFrom,
          contextItem: track.id.toString(),
        );

  @override
  Map<String, Object> toJson() {
    final json = super.toJson();
    json['radioSessionId'] = session.id;
    json['isFromAutoflow'] = isFromAutoflow;
    json['batchId'] = session.batchId;

    return json;
  }
}

final class PlayInfoAlbum extends PlayInfoBase {
  PlayInfoAlbum(super.track)
      : super(
          context: PlayInfoContext.album,
          from: 'desktop-own_collection-collection_new_albums-default',
          contextItem: track.firstAlbumId.toString(),
        );
}

final class PlayInfoPlaylist extends PlayInfoBase {
  late final String playlistId;

  PlayInfoPlaylist(super.track, Playlist playlist)
      : super(
          context: PlayInfoContext.playlist,
          from: 'desktop-own_collection-collection_playlists-default',
          contextItem: '${playlist.uid}:${playlist.kind}',
        ) {
    playlistId = contextItem;
  }

  @override
  Map<String, Object> toJson() {
    final map = super.toJson();
    map['playlistId'] = playlistId;

    return map;
  }
}

final class PlayInfoArtist extends PlayInfoBase {
  PlayInfoArtist(super.track)
      : super(
          context: PlayInfoContext.artist,
          from: 'desktop-own_collection-collection_artists-default',
          contextItem: track.artists.first.id.toString(),
        );
}

final class PlayInfoTracks extends PlayInfoBase {
  PlayInfoTracks(super.track)
      : super(
          context: PlayInfoContext.playlist,
          from: 'desktop-own_collection-collection_playlists-default',
          contextItem: track.id,
        );
}
