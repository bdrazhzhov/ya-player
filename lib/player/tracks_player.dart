part of 'player_base.dart';

final class TracksPlayer extends PlayerBase {
  final TracksQueue queue;

  TracksPlayer({required this.queue});

  @override
  Future<void> playByIndex(int? index) async {
    Track? track;
    if(index == null) {
      track = queue.currentTrack;
    }
    else {
      track = await queue.moveTo(index);
    }

    if(track == null) return;

    if(track == _currentPlayInfo?.track) {
      _audioPlayer.play();
    }
    else {
      await _stop();
      _appState.queueTracks.value = queue.tracks.toList();
      _playTrack(track, queue.from);
    }
  }

  Future<void> _stop() async {
    if(_currentPlayInfo == null) return;

    _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.current;
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    _currentPlayInfo = null;
  }

  @override
  void next() async {
    playByIndex(queue.currentIndex + 1);
  }

  @override
  void previous() async {
    playByIndex(queue.currentIndex - 1);
  }
}
