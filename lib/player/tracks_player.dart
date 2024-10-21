part of 'player_base.dart';

final class TracksPlayer extends PlayerBase {
  final PlaybackQueueBase queue;

  TracksPlayer({required this.queue});

  @override
  void play(int index) async {
    Track? track = await queue.moveTo(index);
    if(track == null) return;

    if(track == _appState.trackNotifier.value) {
      _appState.play();
    }
    else {
      await _stop();
      _appState.queueTracks.value = queue.tracks.toList();
      playTrack(track, queue.from);
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
    play(queue.currentIndex + 1);
  }

  @override
  void previous() async {
    play(queue.currentIndex - 1);
  }
}
