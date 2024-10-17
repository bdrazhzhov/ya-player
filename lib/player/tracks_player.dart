
import '/models/music_api/track.dart';
import 'playback_queue_base.dart';
import 'player_base.dart';

class TracksPlayer extends PlayerBase {
  final PlaybackQueueBase queue;

  TracksPlayer({required this.queue});

  @override
  void play(int index) async {
    Track? track = await queue.moveTo(index);
    if(track == null) return;

    if(track == appState.trackNotifier.value) {
      appState.play();
    }
    else {
      await _stop();
      appState.queueTracks.value = queue.tracks.toList();
      playTrack(track, queue.from);
    }
  }

  Future<void> _stop() async {
    if(currentPlayInfo == null) return;

    currentPlayInfo!.totalPlayed = appState.progressNotifier.value.current;
    await musicApi.sendPlayingStatistics(currentPlayInfo!.toYmPlayAudio());
    currentPlayInfo = null;
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
