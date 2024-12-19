part of 'player_base.dart';

final class TracksPlayer extends PlayerBase {
  final TracksQueue queue;

  TracksPlayer({required this.queue}) {
    _appState.playbackSpeedNotifier.addListener((){
      _audioPlayer.setRate(_appState.playbackSpeedNotifier.value);
    });
    _appState.canGoNextNotifier.value = true;
    _appState.canGoPreviousNotifier.value = false;
    _appState.canShuffleNotifier.value = true;
    _appState.canRepeatNotifier.value = true;
  }

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
      _stop();
      _appState.queueTracks.value = queue.tracks.toList();
      _playTrack(track, queue.from);
    }

    _appState.canGoNextNotifier.value = queue.canGoNext;
    _appState.canGoPreviousNotifier.value = queue.canGoPrevious;
  }

  Future<void> _stop() async {
    if(_currentPlayInfo == null) return;

    _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.current;
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    _currentPlayInfo = null;
  }

  @override
  void next() async {
    int index = queue.currentIndex + 1;

    if(_appState.shuffleNotifier.value) {
      index = Random().nextInt(queue.length);
    }
    else {
      switch(_appState.repeatNotifier.value) {
        case RepeatMode.on:
          if(index == queue.length) {
            index = 0;
          }
        case RepeatMode.one:
          index = queue.currentIndex;
        case RepeatMode.off:
          //
      }
    }

    playByIndex(index);
  }

  @override
  void previous() async {
    int index = queue.currentIndex - 1;

    if(_appState.shuffleNotifier.value) {
      index = Random().nextInt(queue.length);
    }
    else {
      switch(_appState.repeatNotifier.value) {
        case RepeatMode.on:
          if(index == -1) {
            index = queue.length - 1;
          }
        case RepeatMode.one:
          index = queue.currentIndex;
        case RepeatMode.off:
          //
      }
    }

    playByIndex(index);
  }
}
