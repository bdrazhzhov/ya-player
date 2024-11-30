part of 'player_base.dart';

final class StationPlayer extends PlayerBase {
  final StationQueue queue;

  StationPlayer({required this.queue});

  @override
  Future<void> playByIndex(int? index) async {
    Track? track = await queue.next();
    if(track == null) return;

    _appState.currentStationNotifier.value = queue.station;
    _appState.queueTracks.value = [];
    await _musicApi.sendStationTrackFeedback(queue.station.id, null, 'radioStarted', null);

    return _playTrack(track, queue.station.from);
  }

  @override
  void next() async {
    Track? track;

    _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.current;
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());

    Track? currentTrack = _currentPlayInfo!.track;
    final bool isSkipped = _appState.progressNotifier.value.current.inSeconds < currentTrack.duration!.inSeconds;
    final String feedback = isSkipped ? 'skip' : 'trackFinished';
    await _musicApi.sendStationTrackFeedback(_appState.currentStationNotifier.value!.id,
        currentTrack, feedback, _currentPlayInfo!.totalPlayed);

    if(isSkipped) {
      track = await queue.skip();
    }
    else {
      track = await queue.next();
    }

    if(track == null) return;

    await _addTrackToPlayer(track);

    _appState.trackNotifier.value = track;
    _currentPlayInfo = PlayInfo(track, queue.station.from);
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    await _musicApi.sendStationTrackFeedback(_appState.currentStationNotifier.value!.id,
          _currentPlayInfo!.track, 'trackStarted', _currentPlayInfo!.totalPlayed);
    await queue.updatePosition(isInteractive: isSkipped);

    if(isSkipped) {
      await queue.preloadNewTracks();
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
}
