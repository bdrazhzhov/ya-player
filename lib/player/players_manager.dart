import '/services/audio_handler.dart';
import '/app_state.dart';
import '/services/service_locator.dart';
import '/player/player_base.dart';
import 'playback_queue_base.dart';
import 'tracks_source.dart';

class PlayersManager {
  PlayerBase? player;
  TracksSource? currentPageTracksSourceData;
  TracksSource? _tracksSourceData;
  final _appState = getIt<AppState>();

  PlayersManager() {
    _appState.trackSkipStream.listen((TrackSkipType skipType){
      switch(skipType) {
        case TrackSkipType.next: player?.next();
        case TrackSkipType.previous: player?.previous();
      }
    });
  }

  void play(int index) {
    if(currentPageTracksSourceData == null) return;

    if(_tracksSourceData != currentPageTracksSourceData) {
      _tracksSourceData = currentPageTracksSourceData;
      final queue = PlaybackQueueBase(currentPageTracksSourceData!);
      player = PlayerBase(queue: queue);
    }

    player!.play(index);
  }

  void next(){
    if(player == null) return;

    player!.next();
  }

  void previous() {
    if(player == null) return;

    player!.previous();
  }
}
