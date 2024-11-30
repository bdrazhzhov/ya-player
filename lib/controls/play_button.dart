import 'package:flutter/material.dart';

import '/player/players_manager.dart';
import '/app_state.dart';
import '/notifiers/play_button_notifier.dart';
import '/services/service_locator.dart';

class PlayButton extends StatelessWidget {
  PlayButton({super.key,});

  final AppState _appState = getIt<AppState>();
  final _player = getIt<PlayersManager>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _appState.playButtonNotifier,
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
              onPressed: () => _player.play(),
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 40.0,
              onPressed: _player.pause,
            );
        }
      },
    );
  }
}
