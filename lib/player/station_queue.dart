import 'package:flutter/foundation.dart';

import '../models/music_api/queue.dart';
import '../models/music_api/station.dart';
import '../models/music_api/track.dart';
import 'playback_queue_base.dart';
import '../music_api.dart';
import '../services/service_locator.dart';

class StationQueue extends PlaybackQueueBase
{
  final Station station;
  late final String _queueName;
  String? _id;

  final _musicApi = getIt<MusicApi>();

  StationQueue({
    required this.station,
    required super.tracks
  }) {
    String stationId = station.id.type != 'user' ? '${station.id.type}_' : '';
    stationId += station.id.tag;
    _queueName = 'desktop_win-radio-radio_$stationId-default';
  }

  @override
  Future<Track?> next() async {
    Track? track = await super.next();
    
    if(currentIndex == 0) {
      await _createQueueTracks();
    }
    else if(tracks.length - currentIndex <= 3) {
      await _preloadNewTracks();
    }
    else if(currentIndex == tracks.length - 1) {
      await _preloadNewTracks();
      await _createQueue(tracks);
    }

    if(_id != null && currentIndex >= 0) {
      await _musicApi.updateQueuePosition(_id!, currentIndex);
    }

    return track;
  }

  @override
  Future<Track?> moveTo(int index) async {
    Track? track = await super.moveTo(index);

    if(track != null) {
      await _musicApi.updateQueuePosition(_id!, currentIndex);
    }

    return track;
  }

  Future<void> _createQueueTracks() async {
    final List<Track> tracks = await _musicApi.stationTacks(station.id, _lastTrackIds());
    
    await _createQueue(tracks);
  }

  Future<void> _createQueue(List<Track> tracks) async {
    trackMapper(track) => QueueTrack(
        track.id.toString(),
        track.firstAlbumId.toString(),
        _queueName
    );
    final List<QueueTrack> queueTracks = tracks.map(trackMapper).toList();

    _id = await _musicApi.createQueueForStation(station, queueTracks);
  }

  Future<void> _preloadNewTracks() async {
    final List<Track> tracks = await _musicApi.stationTacks(station.id, _lastTrackIds());
    addAll(tracks);
    debugPrint('Added tracks: ${tracks.map((e) => e.title)}');
  }

  List<int> _lastTrackIds() => tracks.reversed.take(3).map((track) => track.id).toList();
}
