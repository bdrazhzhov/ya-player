import 'package:flutter/foundation.dart';

import '/models/music_api/queue.dart';
import '/models/music_api/station.dart';
import '/models/music_api/track.dart';
import 'playback_queue_base.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import 'tracks_source.dart';

class StationQueue extends PlaybackQueueBase
{
  final Station station;

  String? _id;
  @override
  String? get id => _id;

  final _musicApi = getIt<MusicApi>();

  StationQueue({ required this.station }) : super(TracksSource(
      sourceType: TracksSourceType.radio,
      source: station
  ));

  @override
  Future<Track?> next() async {
    if(currentIndex == -1 && tracks.isEmpty) {
      await _preloadNewTracks();
      await _createQueue(tracks);
    }
    else if(tracks.length - currentIndex <= 3) {
      await _preloadNewTracks();
    }
    else if(tracks.isNotEmpty && currentIndex == tracks.length - 1) {
      await _createQueue(tracks);
    }

    Track? track = await super.next();

    if(_id != null && currentIndex >= 0) {
      await _musicApi.updateQueuePosition(id!, currentIndex);
    }

    return track;
  }

  @override
  Future<Track?> previous() async {
    Track? track = await super.previous();

    if(track != null) {
      await _musicApi.updateQueuePosition(id!, currentIndex);
    }

    return track;
  }

  @override
  Future<Track?> moveTo(int index) async {
    if(currentIndex == -1) {
      return next();
    }

    return null;
  }

  Future<void> _createQueue(Iterable<Track> tracks) async {
    trackMapper(track) => QueueTrack(
        track.id.toString(),
        track.firstAlbumId.toString(),
        station.from
    );
    final List<QueueTrack> queueTracks = tracks.map(trackMapper).toList();

    _id = await _musicApi.createQueueForStation(station, queueTracks);
  }

  Future<void> _preloadNewTracks() async {
    final List<Track> tracks = await _musicApi.stationTacks(station.id, _lastTrackIds());
    addAll(tracks);
    debugPrint('Added tracks: ${tracks.map((e) => e.title)}');
  }

  List<int> _lastTrackIds() => tracks.toList().reversed.take(3).map((track) => track.id).toList();
}
