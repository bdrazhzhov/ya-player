import 'package:flutter/material.dart';

import '/app_state.dart';
import '/services/service_locator.dart';

class ShuffleButton extends StatelessWidget {
  final _appState = getIt<AppState>();

  ShuffleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appState.canShuffleNotifier,
      builder: (_, isEnabled, __) {
        return IconButton(
          iconSize: 26,
          onPressed: isEnabled ? _onButtonPress : null,
          icon: ValueListenableBuilder<bool>(
            valueListenable: _appState.shuffleNotifier,
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
    _appState.shuffleNotifier.value = !_appState.shuffleNotifier.value;
  }
}
