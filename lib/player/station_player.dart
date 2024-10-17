
import 'package:meta/meta.dart';

import '/models/music_api/track.dart';
import 'player_base.dart';
import 'station_queue.dart';

class StationPlayer extends PlayerBase {
  final StationQueue queue;

  StationPlayer({required this.queue});

  @override
  void play(int index) async {
    Track? track = await queue.moveTo(0);
    if(track == null) return;

    appState.currentStationNotifier.value = queue.station;
    appState.queueTracks.value = [];

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
    if(currentPlayInfo != null) {
      currentPlayInfo!.totalPlayed = appState.progressNotifier.value.current;
      if(appState.currentStationNotifier.value != null) {
        final bool isSkipped = appState.progressNotifier.value.current.inMilliseconds / track.duration!.inMilliseconds < 0.9;
        final String feedback = isSkipped ? 'skip' : 'trackFinished';
        musicApi.sendStationTrackFeedback(appState.currentStationNotifier.value!.id,
            currentPlayInfo!.track, feedback, currentPlayInfo!.totalPlayed);
      }
    }

    await super.playTrack(track, queue.station.from);

    if(appState.currentStationNotifier.value != null) {
      await musicApi.sendStationTrackFeedback(appState.currentStationNotifier.value!.id,
          currentPlayInfo!.track, 'trackStarted', currentPlayInfo!.totalPlayed);
    }
  }
}