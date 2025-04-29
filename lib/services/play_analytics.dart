import 'dart:convert';

import 'package:audio_player_gst/events.dart';

import '/player/player.dart';
import '/models/music_api_types.dart';
import '/models/play_info.dart';
import 'app_state.dart';
import 'audio_player.dart';
import 'logger.dart';
import 'music_api.dart';
import 'service_locator.dart';

class PlayAnalytics {
  final _stopwatch = Stopwatch();
  bool _isSeeking = false;
  PlayInfoBase? _playInfo;

  final _audioPlayer = getIt<AudioPlayer>();
  final _musicApi = getIt<MusicApi>();

  void start() {
    _audioPlayer.playingStateNotifier.addListener((){
      _processState(_audioPlayer.playingStateNotifier.value);
    });
    _audioPlayer.seekStream.listen((_){ _playInfo?.seek = true; _isSeeking = true; });

    // getIt<NewPlayer>().startTrackStream.listen(_onStartTrack);
    getIt<Player>().beforeNewTrackStartedEvent.addHandler(_onBeforeTrackStart);
  }

  void _processState(PlayingState state) {
    switch(state) {
      case PlayingState.pending:
      case PlayingState.idle: break;
      case PlayingState.ready:
        _stopwatch.reset();
        _playInfo?.seek = false;
        _playInfo?.pause = false;
      case PlayingState.playing:
        _isSeeking = false;
        _stopwatch.start();
      case PlayingState.paused:
        if(!_isSeeking) _playInfo?.pause = true;
        _stopwatch.stop();
      case PlayingState.completed:
        _onTrackFinish();
      case PlayingState.unknown:
    }
  }

  Future<void> _onBeforeTrackStart(Track? track) async {
    if(track == null) return;

    final playContext = getIt<AppState>().playContext;
    switch (playContext) {
      case RadioSession():
        _playInfo = PlayInfoRadio(track, playContext);
      case Playlist():
        _playInfo = PlayInfoPlaylist(track, playContext);
      case Artist():
        _playInfo = PlayInfoArtist(track);
      case Album():
        _playInfo = PlayInfoAlbum(track);
      case List<Track>():
        _playInfo = PlayInfoTracks(track);
      default:
        logger.w('Unknown context object: $playContext');
        return;
    }

    _musicApi.plays(_playInfo!);
    // logger.i('<${track.title}> — Current PlayInfo: ${jsonEncode(_playInfo?.toJson())}');
  }

  void _onTrackFinish() {
    _stopwatch.stop();
    _playInfo?.endPosition = _audioPlayer.trackDurationNotifier.value.position;
    _playInfo?.totalPlayed = _stopwatch.elapsed;
    logger.i('Previous PlayInfo: ${jsonEncode(_playInfo?.toJson())}');
    _musicApi.plays(_playInfo!);
  }
}
