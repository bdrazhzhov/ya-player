import 'package:audio_service/audio_service.dart';
import 'package:meta/meta.dart';

import '/services/audio_handler.dart';
import '/models/play_info.dart';
import '/app_state.dart';
import '/models/music_api/track.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import 'playback_queue_base.dart';

class PlayerBase {
  PlayInfo? _currentPlayInfo;
  final _musicApi = getIt<MusicApi>();
  final _appState = getIt<AppState>();
  final _audioHandler = getIt<MyAudioHandler>();

  final PlaybackQueueBase queue;

  PlayerBase({required this.queue});

  void play(int index) async {
    Track? track = await queue.moveTo(index);
    if(track == null) return;

    if(track == _appState.trackNotifier.value) {
      _appState.play();
    }
    else {
      await _stop();
      return playTrack(track);
    }
  }

  Future<void> _stop() async {
    if(_currentPlayInfo == null) return;

    _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.current;
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    _currentPlayInfo = null;
  }

  void next() async {
    play(queue.currentIndex + 1);
  }

  void previous() async {
    play(queue.currentIndex - 1);
  }

  @protected
  Future<void> playTrack(Track track) async {
    await _addTrackToHandler(track);

    _appState.trackNotifier.value = track;
    _appState.trackLikeNotifier.value = _appState.isLikedTrack(track);
    _currentPlayInfo = PlayInfo(track, queue.from);

    _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
  }

  Future<void> _addTrackToHandler(Track track) async {
    String? url = await _musicApi.trackDownloadUrl(track.id);

    if(url == null) return;

    Uri? artUri;
    if(track.coverUri != null) {
      artUri = Uri.parse(MusicApi.imageUrl(track.coverUri!, '260x260'));
    }

    final mediaItem = MediaItem(
        id: track.id.toString(),
        title: track.title,
        artist: track.artist,
        album: track.albums.first.title,
        duration: track.duration,
        artUri: artUri,
        extras: {'url': url}
    );

    _audioHandler.playTrack(mediaItem);
  }
}
