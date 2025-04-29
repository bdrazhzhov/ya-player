import 'dart:convert';

import '/models/music_api/track.dart';
import '/player/playback_queue.dart';
import 'player.dart';
import '/services/service_locator.dart';
import '/models/music_api/radio_feedback.dart';
import '/models/music_api/radio_session.dart';
import '/models/music_api/station.dart';
import '/models/play_info.dart';
import '/services/audio_player.dart';
import '/services/logger.dart';
import '/services/music_api.dart';

class RadioManager {
  final List<RadioFeedback> _radioFeedbacks = [];
  late RadioSession _session;
  final _musicApi = getIt<MusicApi>();
  final _audioPlayer = getIt<AudioPlayer>();
  final _queue = getIt<PlaybackQueue>();

  void _init() {
    _radioFeedbacks.clear();

    getIt<Player>().beforeNewTrackStartedEvent.addHandler(_onBeforeTrackStart);
    getIt<Player>().trackFinishedEvent.addHandler(_onTrackFinished);
    // getIt<NewPlayer>().trackLoadedEvent.addHandler(_onTrackLoaded);
    getIt<Player>().beforeNextTrackEvent.addHandler(_onBeforeNextTrack);
  }

  Future<RadioSession> start(Station station) async {
    final session = NewRadioSessionRequest(
      includeTracksInResponse: true,
      includeWaveModel: true,
      seeds: [station.id.toString()],
    );
    _session = await _musicApi.startRadioSession(session);

    _init();

    return _session;
  }

  Future<RadioSession> restore({
    required String sessionId,
    required List<String> queue,
    required List<String> seeds,
  }) async {
    final newRequest = NewRadioSessionRequest(
      includeWaveModel: true,
      includeTracksInResponse: true,
      seeds: seeds,
      queue: queue,
    );
    _session = await _musicApi.cloneRadioSession(sessionId, newRequest);

    _init();

    return _session;
  }

  void stop() {
    getIt<Player>().beforeNewTrackStartedEvent.removeHandler(_onBeforeTrackStart);
    getIt<Player>().trackFinishedEvent.removeHandler(_onTrackFinished);
    // getIt<NewPlayer>().trackLoadedEvent.removeHandler(_onTrackLoaded);
    getIt<Player>().beforeNextTrackEvent.removeHandler(_onBeforeNextTrack);
    _radioFeedbacks.clear();
  }

  Future<void> _loadTracksBatch() async {
    final prevTracks = _queue.tracks.map((t) => t.id).toList();

    List<Track> batch = await _musicApi.loadRadioBatch(
      sessionId: _session.id,
      feedbacks: _radioFeedbacks,
      queue: _queue.tracks.map((t) => '${t.id}:${t.firstAlbumId}').toList(),
    );
    _radioFeedbacks.clear();
    _queue.replaceTracksLeft(batch);
    logger.i('$prevTracks\n${_queue.tracks.map((t) => t.id).toList()}');
  }

  Future<void> _onBeforeTrackStart(Track track) async {
    final feedback = RadioFeedback(
      batchId: track.batchId,
      event: RadioEvent(
        type: RadioEventType.trackStarted,
        from: PlayInfoRadio.defaultFrom,
        trackId: '${track.id}:${track.firstAlbumId}',
        totalPlayed: Duration.zero,
      ),
    );

    await _musicApi.sendRadioFeedback(sessionId: _session.id, feedback: feedback);
    logger.i('Radio feedback: ${jsonEncode(feedback.toJson())}');
  }

  Future<void> _onBeforeNextTrack(Track track) async {
    logger.i('Processing previous radio track: ${track.title}');

    final currentPosition = _audioPlayer.trackDurationNotifier.value.position;
    final Duration diff = track.duration! - currentPosition;
    final eventType = diff.inSeconds > 1 ? RadioEventType.skip : RadioEventType.trackFinished;

    _radioFeedbacks.add(RadioFeedback(
      batchId: track.batchId,
      event: RadioEvent(
        type: eventType,
        from: PlayInfoRadio.defaultFrom,
        trackId: '${track.id}:${track.firstAlbumId}',
        totalPlayed: currentPosition,
      ),
    ));

    if(eventType == RadioEventType.skip) {
      // skip following tracks and load next batch of radio tracks
      await _loadTracksBatch();
    }
  }

  Future<void> _onTrackFinished(Track track) async {
    logger.i('Radio track finished: ${track.title}');

    if(_queue.canGoNext) return;

    logger.i('Loading fresh batch of radio tracks');

    await _loadTracksBatch();
  }
}
