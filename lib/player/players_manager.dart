import '/models/music_api/station.dart';
import '/player/player_base.dart';
import 'playback_queue_base.dart';
import 'station_queue.dart';
import 'tracks_source.dart';

class PlayersManager {
  PlayerBase? _player;
  TracksSource? currentPageTracksSourceData;
  TracksSource? _tracksSourceData;

  void play(int index) {
    if(currentPageTracksSourceData == null) return;

    if(_tracksSourceData != currentPageTracksSourceData) {
      _tracksSourceData = currentPageTracksSourceData;

      if(_player != null) _player!.cleanUp();

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
