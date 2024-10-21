part of 'player_base.dart';

final class StationPlayer extends PlayerBase {
  final StationQueue queue;

  StationPlayer({required this.queue});

  @override
  void play(int index) async {
    Track? track = await queue.moveTo(0);
    if(track == null) return;

    _appState.currentStationNotifier.value = queue.station;
    _appState.queueTracks.value = [];

    return playTrack(track, queue.station.from);
  }

  @override
  void next() async {
    Track? track = await queue.next();
    if(track == null) return;

    return playTrack(track, queue.station.from);
  }

  @override
  void previous() async {
    Track? track = await queue.previous();
    if(track == null) return;

    return playTrack(track, queue.station.from);
  }

  @override @protected
  Future<void> playTrack(Track track, String from) async {
    if(_currentPlayInfo != null) {
      _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.current;
      if(_appState.currentStationNotifier.value != null) {
        final bool isSkipped = _appState.progressNotifier.value.current.inMilliseconds / track.duration!.inMilliseconds < 0.9;
        final String feedback = isSkipped ? 'skip' : 'trackFinished';
        _musicApi.sendStationTrackFeedback(_appState.currentStationNotifier.value!.id,
            _currentPlayInfo!.track, feedback, _currentPlayInfo!.totalPlayed);
      }
    }

    await super.playTrack(track, queue.station.from);

    if(_appState.currentStationNotifier.value != null) {
      await _musicApi.sendStationTrackFeedback(_appState.currentStationNotifier.value!.id,
          _currentPlayInfo!.track, 'trackStarted', _currentPlayInfo!.totalPlayed);
    }
  }
}
