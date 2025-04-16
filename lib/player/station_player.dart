part of 'player_base.dart';

final class StationPlayer extends PlayerBase {
  final StationQueue queue;

  StationPlayer({required this.queue}) {
    _appState.stationSettingsNotifier.addListener(_updateStationSettings);
    _playerState.rateNotifier.value = 1.0;
    _playerState.canNextNotifier.value = true;
    _playerState.canPrevNotifier.value = false;
    _playerState.canShuffleNotifier.value = false;
    _playerState.canRepeatNotifier.value = false;
    _playerState.shuffleNotifier.value = false;
    _playerState.repeatNotifier.value = RepeatMode.off;
  }

  @override
  Future<void> playByIndex(int? index) async {
    if(_currentPlayInfo != null) {
      _audioPlayer.play();
      return;
    }

    _appState.playButtonNotifier.value = ButtonState.loading;

    Track? track = await queue.next();
    if(track == null) return;

    _appState.currentStationNotifier.value = queue.station;
    _appState.queueTracks.value = [];
    await _musicApi.sendStationTrackFeedback(queue.station.id, null, 'radioStarted', null);

    return _playTrack(track, queue.station.from);
  }

  @override
  void next() async {
    _appState.playButtonNotifier.value = ButtonState.loading;

    Track? track;

    _currentPlayInfo!.totalPlayed = _playerState.progressNotifier.value.position;
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());

    Track? currentTrack = _currentPlayInfo!.track;
    final bool isSkipped = _playerState.progressNotifier.value.position.inSeconds < currentTrack.duration!.inSeconds;
    final String feedback = isSkipped ? 'skip' : 'trackFinished';
    await _musicApi.sendStationTrackFeedback(_appState.currentStationNotifier.value!.id,
        currentTrack, feedback, _currentPlayInfo!.totalPlayed);

    if(isSkipped) {
      track = queue.skip();
    }
    else {
      track = await queue.next();
    }

    if(track == null) return;

    _playerState.trackNotifier.value = track;
    _currentPlayInfo = PlayInfo(track, queue.station.from);
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    await _musicApi.sendStationTrackFeedback(_appState.currentStationNotifier.value!.id,
          _currentPlayInfo!.track, 'trackStarted', _currentPlayInfo!.totalPlayed);
    queue.updatePosition(isInteractive: isSkipped);

    await _addTrackToPlayer(track);

    if(isSkipped) {
      await queue.loadTracks();
    }
  }

  @override
  void previous() async {}

  @override
  Future<void> _playTrack(Track track, String from) async {
    await super._playTrack(track, queue.station.from);
    final futures = [
      _musicApi.sendStationTrackFeedback(_appState.currentStationNotifier.value!.id,
          _currentPlayInfo!.track, 'trackStarted', _currentPlayInfo!.totalPlayed),
      queue.updatePosition()
    ];

    await Future.wait(futures);
  }

  void _updateStationSettings() async {
    await _musicApi.updateStationSettings2(
        queue.station.id, _appState.stationSettingsNotifier.value);
    await queue.reloadLastTracks();
  }
}
