import 'package:flutter/foundation.dart';

import '/player/queue_factory.dart';
import '/models/music_api/queue.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import '/models/music_api/track.dart';
import '/models/music_api/station.dart';

part 'tracks_queue.dart';
part 'station_queue.dart';

abstract base class PlaybackQueue {
  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  Future<Track?> next();
}