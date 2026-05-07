import 'package:flutter/material.dart';

import '/models/music_api/track.dart';
import '/services/app_state.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'track_list/play_pause_cover.dart';

class PlayPauseButton extends StatefulWidget {
  final Track track;
  final double size;

  const PlayPauseButton({super.key, required this.track, required this.size});

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  final playerState = getIt<PlayerState>();
  final appState = getIt<AppState>();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    appState.trackNotifier.addListener(onStateChange);
    playerState.playBackStateNotifier.addListener(onStateChange);
    onStateChange();
  }

  @override
  void dispose() {
    appState.trackNotifier.removeListener(onStateChange);
    playerState.playBackStateNotifier.removeListener(onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayPauseCover(buttonSize: widget.size, isPlaying: isPlaying);
  }

  void onStateChange() {
    if (appState.trackNotifier.value != widget.track) return;

    isPlaying =
        playerState.playBackStateNotifier.value == PlayBackState.playing;
    setState(() {});
  }
}
