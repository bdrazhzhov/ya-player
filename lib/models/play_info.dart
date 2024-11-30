import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import 'music_api/track.dart';

class PlayInfo {
  final Track track;
  final String from;
  var totalPlayed = const Duration();
  final String _uuid;

  PlayInfo(this.track, this.from)
      : _uuid = const Uuid().v4();

  Map<String, String> toYmPlayAudio() {
    final String dateTime = '${DateFormat('y-MM-ddTHH:mm:ss.S').format(DateTime.now().toUtc())}Z';
    final totalPlayedSeconds = (totalPlayed.inMilliseconds / 1000.0).toString();

    return {
      'track-id': track.id.toString(),
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