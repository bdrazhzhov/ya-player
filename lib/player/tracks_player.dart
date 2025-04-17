part of 'player_base.dart';

final class TracksPlayer extends PlayerBase {
  final TracksQueue queue;
  int _currentIndex = -1;

  TracksPlayer({required this.queue}) {
    _playerState.rateNotifier.addListener((){
      _audioPlayer.setRate(_playerState.rateNotifier.value);
    });
    _playerState.canNextNotifier.value = true;
    _playerState.canPrevNotifier.value = false;
    _playerState.canShuffleNotifier.value = true;
    _playerState.canRepeatNotifier.value = true;
  }

  @override
  Future<void> playByIndex(int? index) async {
    _appState.playButtonNotifier.value = ButtonState.loading;

    Track? track;
    if(index == null || _currentIndex == index) {
      track = queue.currentTrack;
      _currentIndex = queue.currentIndex;
    }
    else {
      track = await queue.moveTo(index);
      _currentIndex = index;
    }

    _playerState.canNextNotifier.value = queue.canGoNext;
    _playerState.canPrevNotifier.value = queue.canGoPrevious;

    if(track == null) {
      _appState.playButtonNotifier.value = ButtonState.paused;
      return;
    }

    if(track == _currentPlayInfo?.track && _playerState.repeatNotifier.value != RepeatMode.one) {
      await _audioPlayer.play();
    }
    else {
      await _stop();
      _appState.queueTracks.value = queue.tracks.toList();
      await _playTrack(track, queue.from);
    }
  }

  Future<void> _stop() async {
    if(_currentPlayInfo == null) return;

    _currentPlayInfo!.totalPlayed = _playerState.progressNotifier.value.position;
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    _currentPlayInfo = null;
  }

  @override
  void next() async {
    int index = queue.currentIndex + 1;

    if(_playerState.shuffleNotifier.value) {
      index = Random().nextInt(queue.length);
    }
    else {
      switch(_playerState.repeatNotifier.value) {
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

    if(_playerState.shuffleNotifier.value) {
      index = Random().nextInt(queue.length);
    }
    else {
      switch(_playerState.repeatNotifier.value) {
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
