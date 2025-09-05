import 'package:flutter/material.dart';

class PlayPauseCover extends StatelessWidget {
  const PlayPauseCover({
    super.key,
    required this.buttonSize,
    required this.isPlaying,
  });

  final double buttonSize;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(buttonSize / 2),
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.black,
        ),
      ),
    );
  }
}
