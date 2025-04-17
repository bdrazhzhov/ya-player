part of 'player_base.dart';

final class SingleTrackPlayer extends PlayerBase {
  final Track track;
  bool _playingStarted = false;

  SingleTrackPlayer(this.track);

  @override
  void next() {}

  @override
  Future<void> playByIndex(int? index) async {
    if(_playingStarted) return playPause();

    await _playTrack(track, 'desktop_win-single-track-default');
    _playingStarted = true;
    _playerState.canNextNotifier.value = false;
  }
}
