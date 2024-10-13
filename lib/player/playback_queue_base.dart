import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:ya_player/player/queue_factory.dart';

import '../models/music_api/queue.dart';
import '../music_api.dart';
import '../services/service_locator.dart';
import '/models/music_api/track.dart';
import 'tracks_source.dart';

class PlaybackQueueBase
{
  final TracksSource tracksSource;
  final List<Track> _tracks;
  Iterable<Track> get tracks => _tracks;

  int _currentIndex = -1;

  @protected
  final musicApi = getIt<MusicApi>();

  int get currentIndex => _currentIndex;

  String? _id;
  String? get id => _id;

  final String from;
  
  PlaybackQueueBase(this.tracksSource) :
        from = tracksSourceStrings[tracksSource.sourceType],
        _tracks = tracksSource.getTracks().toList();

  void addAll(List<Track> tracks) {
    _tracks.addAll(tracks);
  }

  void add(Track track) {
    _tracks.add(track);
  }

  Future<Track?> next() async {
    if(_tracks.isEmpty || _currentIndex >= _tracks.length - 1) return null;

    _currentIndex += 1;

    return _tracks[_currentIndex];
  }

  Track? previous() {
    if(_tracks.isEmpty || _currentIndex == 0) return null;

    _currentIndex -= 1;

    return _tracks[_currentIndex];
  }

  Future<Track?> moveTo(int index) async {
    Track? track;

    if(_tracks.isNotEmpty && index >= 0 && index < _tracks.length) {
      _currentIndex = index;
      track = _tracks[index];
    }

    if(track == null) return null;

    if(id == null) {
      final Queue queue = QueueFactory.create(
          tracksSource: tracksSource, currentIndex: currentIndex);
      await createQueue(queue);
    }
    else {
      musicApi.updateQueuePosition(id!, currentIndex);
    }

    return track;
  }

  @protected
  Future<void> createQueue(Queue queue) async {
    _id = await musicApi.createQueue(queue);
  }
}
