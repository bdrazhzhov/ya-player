import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import 'music_api/station.dart';
import 'music_api/track.dart';

class PlayInfo {
  final Track track;
  final StationId stationId;
  var totalPlayed = const Duration();
  late final String _uuid;
  late final String _from;

  PlayInfo(this.track, this.stationId) {
    _from = stationId.type == 'user' ? stationId.tag : "${stationId.type}_${stationId.tag}";
    _uuid = const Uuid().v4();
  }

  Map<String, String> toYmPlayAudio() {
    final String dateTime = '${DateFormat('y-MM-ddTHH:mm:ss.S').format(DateTime.now())}Z';
    final totalPlayedSeconds = (totalPlayed.inMilliseconds / 1000.0).toString();

    return {
      'track-id': track.id.toString(),
      'album-id': track.firstAlbumId.toString(),
      'from-cache': 'False',
      'from': 'desktop_win-radio-radio_$_from-default',
      'play-id': _uuid,
      'timestamp': dateTime,
      'client-now': dateTime,
      'track-length-seconds': (track.duration!.inMilliseconds / 1000.0).toString(),
      'total-played-seconds': totalPlayedSeconds,
      'end-position-seconds': totalPlayedSeconds
    };
  }
}