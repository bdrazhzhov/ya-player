import 'package:flutter/material.dart';

import '/services/app_state.dart';
import '/services/service_locator.dart';

class LikeButton extends StatefulWidget {
  final bool Function() likeCondition;
  final Future<void> Function() onLikeClicked;

  const LikeButton({
    super.key,
    // required this.track,
    required this.likeCondition,
    required this.onLikeClicked,
  });

  // final Track track;

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
        final iconData = widget.likeCondition() ? Icons.favorite : Icons.favorite_border;

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

    await widget.onLikeClicked();

    setState(() {
      isProcessing = false;
    });
  }
}
