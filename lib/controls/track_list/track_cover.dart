import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/models/music_api/can_be_played.dart';
import '/controls/yandex_image.dart';
import 'track_animation_cover.dart';

class TrackCover extends StatefulWidget {
  final CanBePlayed track;
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
    }
  );

  @override
  State<TrackCover> createState() => _TrackCoverState();
}

class _TrackCoverState extends State<TrackCover> with SingleTickerProviderStateMixin {
  static const double size = 50;
  static const double hoverButtonSize = 30;
  static const buttonColor = Color.fromARGB(255, 255, 219, 77);
  static const double coverCornersRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if(widget.trackNumber != null)
            Text(widget.isCurrent ? '' : widget.trackNumber.toString())
          else
            YandexImage(
              uriTemplate: widget.track.coverUri,
              size: 50,
              placeholder: SvgPicture.asset('assets/svg/track_placeholder.svg'),
              borderRadius: coverCornersRadius,
            ),
          if(widget.isCurrent)
            ...[
            if(widget.trackNumber == null)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.75).toInt()),
                  borderRadius: BorderRadius.circular(coverCornersRadius),
                ),
              ),
          // Animation of playing process
          if(!widget.isHovered && widget.isPlaying)
            TrackAnimationCover(
              bgColor: buttonColor,
              radius: hoverButtonSize / 2,
              playAnimation: !widget.isCurrent || widget.isPlaying,
            )
          ],
          // Play/Pause button
          if(widget.isHovered || !widget.isPlaying && widget.isCurrent)
            Container(
              width: hoverButtonSize,
              height: hoverButtonSize,
              decoration: const BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.all(Radius.circular(hoverButtonSize / 2))
              ),
              child: widget.isPlaying && widget.isCurrent
                  ? const Icon(Icons.pause, color: Colors.black)
                  : const Icon(Icons.play_arrow, color: Colors.black)
            ),
        ]
      )
    );
  }
}
