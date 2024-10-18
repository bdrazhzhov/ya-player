import 'package:audio_service/audio_service.dart';
import 'package:meta/meta.dart';

import '/app_state.dart';
import '/models/music_api/track.dart';
import '/models/play_info.dart';
import '/music_api.dart';
import '/services/audio_handler.dart';
import '/services/service_locator.dart';

class PlayerBase {
  @protected
  final musicApi = getIt<MusicApi>();
  @protected
  final appState = getIt<AppState>();
  final _audioHandler = getIt<MyAudioHandler>();
  @protected
  PlayInfo? currentPlayInfo;

  @mustBeOverridden
  void play(int index){}

  @mustBeOverridden
  void next() {}

  @mustBeOverridden
  void previous() {}

  @protected
  Future<void> playTrack(Track track, String from) async {
    await _addTrackToHandler(track);

    appState.trackNotifier.value = track;
    currentPlayInfo = PlayInfo(track, from);
    musicApi.sendPlayingStatistics(currentPlayInfo!.toYmPlayAudio());
  }

  Future<void> _addTrackToHandler(Track track) async {
    String? url = await musicApi.trackDownloadUrl(track.id);

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
