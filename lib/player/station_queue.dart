import 'package:flutter/foundation.dart';

import '/player/queue_factory.dart';
import '/models/music_api/queue.dart';
import '/models/music_api/station.dart';
import '/models/music_api/track.dart';
import '/music_api.dart';
import '/services/service_locator.dart';

final class StationQueue
{
  final List<Track> _tracks = [];
  final _musicApi = getIt<MusicApi>();
  late Queue _queue;
  int _currentIndex = -1;
  int _realIndex = -1;
  Iterable<int> _lastTracksIds = [];

  final Station station;
  StationQueue({ required this.station });

  Future<Track?> next() async {
    if(_tracks.isEmpty && _realIndex == -1) {
      _lastTracksIds = [];
      await preloadNewTracks();
      _queue = await QueueFactory.create(tracksSource: (station, _tracks));
    }
    else if(_tracks.length - _realIndex <= 3) {
      _lastTracksIds = _tracks.skip(_tracks.length - 2).map((t) => t.id);
      await preloadNewTracks();
    }
    else if(_tracks.isNotEmpty && _realIndex == _tracks.length - 1) {
      _lastTracksIds = [];
      await preloadNewTracks();
    }

    Track? track;
    if(_tracks.isEmpty || _realIndex >= _tracks.length - 1) {
      track = null;
    }
    else {
      _currentIndex += 1;
      _realIndex += 1;

      track = _tracks[_realIndex];
      // await updatePosition();
    }

    return track;
  }

  Future<Track> skip() async {
    _currentIndex += 1;
    _realIndex += 1;

    Track track = _tracks[_realIndex];
    _lastTracksIds = _tracks.skip(_realIndex).map((t) => t.id).toList();
    _tracks.removeRange(_realIndex, _tracks.length);
    _realIndex -= 1;

    // await updatePosition();
    // await preloadNewTracks();

    return track;
  }

  Future<void> updatePosition({bool isInteractive = false}) async {
    try {
      await _musicApi.updateQueuePosition(_queue.id!, _currentIndex, isInteractive);
    } on QueueIndexInvalid {
      _queue = await QueueFactory.create(tracksSource: (station, _tracks));
    }
  }

  Future<void> preloadNewTracks() async {
    final Iterable<Track> tracks = await _musicApi.stationTacks(station.id, _lastTracksIds);
    _tracks.addAll(tracks);

    debugPrint('Tracks in queue:\n${_tracks.map((e) => '${e.id} - ${e.title}').join('\n')}');
  }
}
