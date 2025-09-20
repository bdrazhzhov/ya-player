import 'package:flutter/material.dart';

import '/models/music_api/track.dart';
import '/services/app_state.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';

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
  IconData icon = Icons.play_arrow;

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
    final theme = Theme.of(context);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.size / 2)),
      ),
      child: Icon(icon, color: Colors.black),
    );
  }

  void onStateChange() {
    if (appState.trackNotifier.value != widget.track) return;

    final isPlaying = playerState.playBackStateNotifier.value == PlayBackState.playing;
    icon = isPlaying ? Icons.pause : Icons.play_arrow;
    setState(() {});
  }
}
