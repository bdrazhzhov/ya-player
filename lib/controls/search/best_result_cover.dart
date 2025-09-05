import 'package:flutter/material.dart';

import '/controls/track_list/play_pause_cover.dart';
import '/controls/track_list/track_animation_cover.dart';
import '/controls/yandex_image.dart';

class BestResultCover extends StatelessWidget {
  final String? uriTemplate;
  final Color? filterColor;
  final bool hasPlayAnimation;
  final bool hasPlayPause;
  final bool isPlaying;

  const BestResultCover({
    super.key,
    this.uriTemplate,
    this.filterColor,
    required this.hasPlayAnimation,
    required this.hasPlayPause,
    required this.isPlaying,
  });

  static const double hoverButtonSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        YandexImage(
          uriTemplate: uriTemplate,
          width: 80,
          height: 80,
          borderRadius: 40,
          filterColor: filterColor,
        ),
        if (hasPlayAnimation)
          TrackAnimationCover(
            bgColor: theme.primaryColor,
            radius: hoverButtonSize / 2,
            playAnimation: true,
          ),
        if (!hasPlayAnimation && hasPlayPause)
          PlayPauseCover(
            buttonSize: hoverButtonSize,
            isPlaying: isPlaying,
          ),
      ],
    );
  }
}
