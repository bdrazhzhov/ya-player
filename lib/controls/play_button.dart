import 'package:flutter/material.dart';

import '../app_state.dart';
import '../notifiers/play_button_notifier.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: appState.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 40.0,
              height: 40.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 40.0,
              onPressed: appState.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 40.0,
              onPressed: appState.pause,
            );
        }
      },
    );
  }
}
