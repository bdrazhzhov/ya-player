import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/music_api/track.dart';
import '../../music_api.dart';

class TrackCover extends StatefulWidget {
  final Track track;
  final bool isCurrent;
  final bool isPlaying;
  final bool isHovered;
  final void Function(bool isPlaying)? onPressed;

  const TrackCover(
    this.track, {
      super.key,
      required this.isCurrent,
      this.isPlaying = false,
      this.isHovered = false,
      this.onPressed
    }
  );

  @override
  State<TrackCover> createState() => _TrackCoverState();
}

class _TrackCoverState extends State<TrackCover> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;

  static const double size = 50;
  static const double hoverButtonSize = 30;
  static const buttonColor = Color.fromARGB(255, 255, 219, 77);
  static const double coverCornersRadius = 4.0;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    animationController.repeat(reverse: true);
    animation =  Tween(begin: 10.0, end: hoverButtonSize / 2)
        .animate(animationController)
          ..addListener(() => setState(() {}));

    if(widget.isCurrent && !widget.isPlaying) animationController.stop();

    super.initState();
  }


  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          image(),
          if(widget.isCurrent)
            ...[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(coverCornersRadius),
              ),
            ),
          // Animation of playing process
          if(!widget.isHovered && widget.isPlaying)
            Container(
              width: animation.value,
              height: animation.value,
              decoration: const BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.all(Radius.circular(15))
              ),
            )
          ],
          // Play/Pause button
          if(widget.isHovered || !widget.isPlaying && widget.isCurrent)
            Container(
              width: hoverButtonSize,
              height: hoverButtonSize,
              decoration: const BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              child: widget.isPlaying && widget.isCurrent
                  ? const Icon(Icons.pause, color: Colors.black)
                  : const Icon(Icons.play_arrow, color: Colors.black)
            ),
        ]
      )
    );
  }

  Widget image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(coverCornersRadius),
      child: widget.track.coverUri == null
        ? SvgPicture.asset(
            'assets/svg/track_placeholder.svg',
          )
        : CachedNetworkImage(
            fit: BoxFit.fitWidth,
            imageUrl: MusicApi.imageUrl(widget.track.coverUri!, '50x50').toString(),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
    );
  }
}
