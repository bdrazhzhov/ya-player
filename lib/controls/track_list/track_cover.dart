import 'package:flutter/material.dart';

import '/controls/yandex_image.dart';
import '/models/music_api/track.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'play_pause_cover.dart';
import 'track_animation_cover.dart';

class TrackCover extends StatefulWidget {
  final Track track;
  final bool isCurrent;
  final bool isHovered;
  final void Function(bool isPlaying)? onPressed;
  final int? trackNumber;

  static const double size = 50;
  static const double hoverButtonSize = 30;
  static const double coverCornersRadius = 4.0;

  const TrackCover(
    this.track, {
    super.key,
    required this.isCurrent,
    this.isHovered = false,
    this.trackNumber,
    this.onPressed,
  });

  @override
  State<TrackCover> createState() => _TrackCoverState();
}

class _TrackCoverState extends State<TrackCover> {
  final playerState = getIt<PlayerState>();

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    playerState.playBackStateNotifier.addListener(onPlayBackStateChange);
    onPlayBackStateChange();
  }

  @override
  void dispose() {
    playerState.playBackStateNotifier.removeListener(onPlayBackStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: TrackCover.size,
      height: TrackCover.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.trackNumber != null)
            Text(widget.isCurrent ? '' : widget.trackNumber.toString())
          else
            YandexImage(
              uriTemplate: widget.track.coverUri,
              width: 50,
              borderRadius: TrackCover.coverCornersRadius,
            ),
          if (widget.isCurrent) ...[
            if (widget.trackNumber == null)
              Container(
                width: TrackCover.size,
                height: TrackCover.size,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.75).toInt()),
                  borderRadius: BorderRadius.circular(TrackCover.coverCornersRadius),
                ),
              ),
            // Animation of playing process
            if (!widget.isHovered && isPlaying)
              TrackAnimationCover(
                bgColor: theme.primaryColor,
                radius: TrackCover.hoverButtonSize / 2,
                playAnimation: !widget.isCurrent || isPlaying,
              )
          ],
          if (widget.isHovered || !isPlaying && widget.isCurrent)
            PlayPauseCover(
              buttonSize: TrackCover.hoverButtonSize,
              isPlaying: isPlaying && widget.isCurrent,
            ),
        ],
      ),
    );
  }

  void onPlayBackStateChange() {
    if (!widget.isCurrent) return;

    isPlaying = playerState.playBackStateNotifier.value == PlayBackState.playing;
    setState(() {});
  }
}
