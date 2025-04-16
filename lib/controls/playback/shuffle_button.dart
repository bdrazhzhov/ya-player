import 'package:flutter/material.dart';

import '/player_state.dart';
import '/services/service_locator.dart';

class ShuffleButton extends StatelessWidget {
  final _playerState = getIt<PlayerState>();

  ShuffleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _playerState.canShuffleNotifier,
      builder: (_, isEnabled, __) {
        return IconButton(
          iconSize: 26,
          onPressed: isEnabled ? _onButtonPress : null,
          icon: ValueListenableBuilder<bool>(
            valueListenable: _playerState.shuffleNotifier,
            builder: (_, bool isEnabled, __) {
              if(isEnabled) {
                return const Icon(Icons.shuffle_on_outlined);
              }

              return const Icon(Icons.shuffle_outlined);
            }
          )
        );
      }
    );
  }

  void _onButtonPress() {
    _playerState.shuffleNotifier.value = !_playerState.shuffleNotifier.value;
  }
}
