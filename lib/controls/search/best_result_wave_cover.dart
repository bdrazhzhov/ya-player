import 'package:flutter/material.dart';

import '/helpers/color_extension.dart';
import '/models/music_api/radio_session.dart';
import '/models/music_api/search.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'best_result_cover.dart';

class BestResultWaveCover extends StatefulWidget {
  final BestResultWave bestResult;
  final bool isHovered;

  const BestResultWaveCover({super.key, required this.bestResult, required this.isHovered});

  @override
  State<BestResultWaveCover> createState() => _BestResultWaveCoverState();
}

class _BestResultWaveCoverState extends State<BestResultWaveCover> {
  final musicApi = getIt<MusicApi>();
  final appState = getIt<AppState>();
  final playerState = getIt<PlayerState>();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    appState.trackNotifier.addListener(updateState);
    playerState.playBackStateNotifier.addListener(updateState);
    isPlaying = _isPlaying();
  }

  @override
  void dispose() {
    appState.trackNotifier.removeListener(updateState);
    playerState.playBackStateNotifier.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BestResultCover(
      uriTemplate: widget.bestResult.backgroundImageUrl,
      filterColor: widget.bestResult.colors.average.toColor(),
      borderRadius: 40,
      hasPlayAnimation: !widget.isHovered && isPlaying,
      hasPlayPause: widget.isHovered,
      isPlaying: isPlaying,
    );
  }

  bool _isPlaying() {
    if (appState.playContext is! RadioSession) return false;

    final radioSession = appState.playContext as RadioSession;
    if (radioSession.wave.stationId != widget.bestResult.stationId.toString()) return false;

    return playerState.playBackStateNotifier.value == PlayBackState.playing;
  }

  void updateState() {
    isPlaying = _isPlaying();
    setState(() {});
  }
}
