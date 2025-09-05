import 'package:flutter/material.dart';

import '/controls/yandex_image.dart';
import '/models/music_api/track.dart';
import 'play_pause_cover.dart';
import 'track_animation_cover.dart';

class TrackCover extends StatefulWidget {
  final Track track;
  final bool isCurrent;
  final bool isPlaying;
  final bool isHovered;
  final void Function(bool isPlaying)? onPressed;
  final int? trackNumber;

  const TrackCover(
    this.track, {
    super.key,
    required this.isCurrent,
    this.isPlaying = false,
    this.isHovered = false,
    this.trackNumber,
    this.onPressed,
  });

  @override
  State<TrackCover> createState() => _TrackCoverState();
}

class _TrackCoverState extends State<TrackCover> with SingleTickerProviderStateMixin {
  static const double size = 50;
  static const double hoverButtonSize = 30;
  static const double coverCornersRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.trackNumber != null)
            Text(widget.isCurrent ? '' : widget.trackNumber.toString())
          else
            YandexImage(
              uriTemplate: widget.track.coverUri,
              width: 50,
              borderRadius: coverCornersRadius,
            ),
          if (widget.isCurrent) ...[
            if (widget.trackNumber == null)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.75).toInt()),
                  borderRadius: BorderRadius.circular(coverCornersRadius),
                ),
              ),
            // Animation of playing process
            if (!widget.isHovered && widget.isPlaying)
              TrackAnimationCover(
                bgColor: theme.primaryColor,
                radius: hoverButtonSize / 2,
                playAnimation: !widget.isCurrent || widget.isPlaying,
              )
          ],
          if (widget.isHovered || !widget.isPlaying && widget.isCurrent)
            PlayPauseCover(
              buttonSize: hoverButtonSize,
              isPlaying: widget.isPlaying && widget.isCurrent,
            ),
        ],
      ),
    );
  }
}
