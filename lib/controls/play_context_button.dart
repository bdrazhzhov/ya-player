import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/models/music_api/track.dart';
import '/player/player.dart';
import '/services/app_state.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'track_list/track_animation_cover.dart';

class PlayContextButton extends StatefulWidget {
  final Equatable context;
  final Iterable<Track> tracks;
  final int? index;
  final bool hasBeatAnimation;
  const PlayContextButton(
      {super.key,
      required this.context,
      required this.tracks,
      this.index,
      this.hasBeatAnimation = false});

  @override
  State<PlayContextButton> createState() => _PlayContextButtonState();
}

class _PlayContextButtonState extends State<PlayContextButton> {
  final playerState = getIt<PlayerState>();
  final appState = getIt<AppState>();
  bool isPlaying = false;
  bool isLoading = false;
  bool isHovered = false;

  bool get isCurrent =>
      appState.playContext == widget.context ||
      track != null && appState.trackNotifier.value == track;
  Track? get track {
    if (widget.index == null) return null;

    return widget.tracks.elementAt(widget.index!);
  }

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
    final theme = Theme.of(context);

    late final Widget child;

    if (widget.hasBeatAnimation && isPlaying && !isHovered) {
      child = TrackAnimationCover(
        bgColor: theme.primaryColor,
        radius: 25,
        playAnimation: true,
      );
    } else {
      child = IconButton(
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        tooltip: isCurrent ? null : l10n.play_context_tooltip,
        onPressed: isLoading ? null : onPressed,
      );
    }

    return MouseRegion(
      onEnter: (_) {
        isHovered = true;
        setState(() {});
      },
      onExit: (_) {
        isHovered = false;
        setState(() {});
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(child: child),
      ),
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

    await appState.playContent(widget.context, widget.tracks, widget.index);

    isLoading = false;
    setState(() {});
  }
}
