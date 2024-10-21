import 'package:audio_service/audio_service.dart';
import 'package:meta/meta.dart';

import '/app_state.dart';
import '/models/music_api/track.dart';
import '/models/play_info.dart';
import '/music_api.dart';
import '/services/audio_handler.dart';
import '/services/service_locator.dart';
import 'playback_queue_base.dart';
import 'station_queue.dart';

part 'station_player.dart';
part 'tracks_player.dart';

base class PlayerBase {
  final _musicApi = getIt<MusicApi>();
  final _appState = getIt<AppState>();
  final _audioHandler = getIt<MyAudioHandler>();
  PlayInfo? _currentPlayInfo;

  @mustBeOverridden
  void play(int index){}

  @mustBeOverridden
  void next() {}

  @mustBeOverridden
  void previous() {}

  @protected
  Future<void> playTrack(Track track, String from) async {
    await _addTrackToHandler(track);

    _appState.trackNotifier.value = track;
    _currentPlayInfo = PlayInfo(track, from);
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
