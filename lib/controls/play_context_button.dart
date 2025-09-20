import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/models/music_api/track.dart';
import '/player/player.dart';
import '/services/app_state.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';

class PlayContextButton extends StatefulWidget {
  final Equatable context;
  final Iterable<Track> tracks;
  const PlayContextButton({super.key, required this.context, required this.tracks});

  @override
  State<PlayContextButton> createState() => _PlayContextButtonState();
}

class _PlayContextButtonState extends State<PlayContextButton> {
  final playerState = getIt<PlayerState>();
  final appState = getIt<AppState>();
  bool isPlaying = false;
  bool isLoading = false;

  bool get isCurrent => appState.playContext == widget.context;

  @override
  void initState() {
    super.initState();

    onPlaybackStateChange();
    playerState.playBackStateNotifier.addListener(onPlaybackStateChange);
  }

  @override
  void dispose() {
    playerState.playBackStateNotifier.removeListener(onPlaybackStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
      tooltip: isCurrent ? null : l10n.play_context_tooltip,
      onPressed: isLoading ? null : onPressed,
    );
  }

  void onPlaybackStateChange() {
    final isPlaying = playerState.playBackStateNotifier.value == PlayBackState.playing;

    if (isCurrent) {
      this.isPlaying = isPlaying;
      setState(() {});
    } else if (this.isPlaying && !isPlaying) {
      this.isPlaying = false;
      setState(() {});
    }
  }

  void onPressed() async {
    if (isCurrent) {
      getIt<Player>().playPause();
      return;
    }

    isLoading = true;
    setState(() {});

    await appState.playContent(widget.context, widget.tracks);

    isLoading = false;
    setState(() {});
  }
}
