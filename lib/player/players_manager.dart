import 'playback_queue.dart';
import '/player/player_base.dart';

class PlayersManager {
  PlayerBase? _player;

  PlayersManager();

  void setPlayer(PlayerBase player) {
    _player?.cleanUp();
    _player = player;
  }

  void setPlaybackQueue(PlaybackQueue playbackQueue) {
    _player?.cleanUp();

    if(playbackQueue is StationQueue) {
      _player = StationPlayer(queue: playbackQueue);
    }
    else {
      _player = TracksPlayer(queue: playbackQueue as TracksQueue);
    }
  }

  void play([int? index]) => _player?.playByIndex(index);
  void next() => _player?.next();
  void previous() => _player?.previous();
  void pause() => _player?.pause();
}
