import 'package:audio_service/audio_service.dart';

import '/app_state.dart';
import '/models/music_api/track.dart';
import '/models/play_info.dart';
import '/music_api.dart';
import '/services/audio_handler.dart';
import '/services/service_locator.dart';
import 'liked_tracks_queue.dart';
import 'player_base.dart';

class LikedTracksPlayer extends PlayerBase {

  LikedTracksQueue? _queue;
  PlayInfo? _currentPlayInfo;
  final _appState = getIt<AppState>();
  final _musicApi = getIt<MusicApi>();
  final _audioHandler = getIt<MyAudioHandler>();

  @override
  void play(int index) async {
    _queue ??= _createQueue();

    Track? track = await _queue!.moveTo(index);
    if(track == null) return;

    if(track == _appState.trackNotifier.value) {
      _appState.play();
    }
    else {
      await _stop();
      return _playTrack(track);
    }
  }

  @override
  void next() async {
    if(_queue == null) return;

    play(_queue!.currentIndex + 1);
  }

  @override
  void previous() {
    if(_queue == null) return;

    play(_queue!.currentIndex - 1);
  }

  LikedTracksQueue _createQueue()  {
    return LikedTracksQueue(tracks: _appState.likedTracksNotifier.value);
  }

  Future<void> _playTrack(Track track) async {
    await _addTrackToHandler(track);

    _appState.trackNotifier.value = track;
    _appState.trackLikeNotifier.value = _appState.isLikedTrack(track);
    _currentPlayInfo = PlayInfo(track, 'desktop_win-own_tracks-track-default');

    _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
  }

  Future<void> _stop() async {
    if(_currentPlayInfo == null) return;

    _currentPlayInfo!.totalPlayed = _appState.progressNotifier.value.current;
    await _musicApi.sendPlayingStatistics(_currentPlayInfo!.toYmPlayAudio());
    _currentPlayInfo = null;
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
