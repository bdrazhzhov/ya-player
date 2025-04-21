import '/dbus/sleep_inhibitor.dart';
import '/services/service_locator.dart';
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

  Future<void> play([int? index]) async => await _player?.playByIndex(index);
  void next() => _player?.next();
  void previous() => _player?.previous();
  Future<void> pause() async => await _player?.pause();

  void playPause() {
    _player?.playPause();
  }
}
