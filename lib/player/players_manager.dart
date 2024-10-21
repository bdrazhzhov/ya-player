import 'package:ya_player/models/music_api/station.dart';
import 'package:ya_player/player/station_queue.dart';

import '/services/audio_handler.dart';
import '/app_state.dart';
import '/services/service_locator.dart';
import '/player/player_base.dart';
import 'playback_queue_base.dart';
import 'tracks_source.dart';

class PlayersManager {
  PlayerBase? _player;
  TracksSource? currentPageTracksSourceData;
  TracksSource? _tracksSourceData;
  final _appState = getIt<AppState>();

  PlayersManager() {
    _appState.trackSkipStream.listen((TrackSkipType skipType){
      switch(skipType) {
        case TrackSkipType.next: _player?.next();
        case TrackSkipType.previous: _player?.previous();
      }
    });
  }

  void play(int index) {
    if(currentPageTracksSourceData == null) return;

    if(_tracksSourceData != currentPageTracksSourceData) {
      _tracksSourceData = currentPageTracksSourceData;
      if(_tracksSourceData!.sourceType == TracksSourceType.radio) {
        final queue = StationQueue(station: _tracksSourceData!.source as Station);
        _player = StationPlayer(queue: queue);
      }
      else {
        final queue = PlaybackQueueBase(_tracksSourceData!);
        _player = TracksPlayer(queue: queue);
      }
    }

    _player!.play(index);
  }

  void next(){
    if(_player == null) return;

    _player!.next();
  }

  void previous() {
    if(_player == null) return;

    _player!.previous();
  }
}
