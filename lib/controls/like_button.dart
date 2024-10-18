import 'package:flutter/material.dart';

import '../models/music_api/track.dart';
import '/app_state.dart';
import '/services/service_locator.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.track,
  });

  final Track track;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final appState = getIt<AppState>();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.likedTracksNotifier,
      builder: (_, value, __) {
        final iconData = appState.isLikedTrack(widget.track) ? Icons.favorite : Icons.favorite_border;

        return IconButton(
          icon: Icon(iconData),
          onPressed: isProcessing ? null : buttonClick
        );
      }
    );
  }

  void buttonClick() async {
    setState(() {
      isProcessing = true;
    });

    await appState.likeTrack(widget.track);

    setState(() {
      isProcessing = false;
    });
  }
}
