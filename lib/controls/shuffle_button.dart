import 'package:flutter/material.dart';

import '/dbus/mpris/mpris_player.dart';
import '/app_state.dart';
import '/services/service_locator.dart';

class ShuffleButton extends StatelessWidget {
  final _appState = getIt<AppState>();
  final _mpris = getIt<OrgMprisMediaPlayer2>();

  ShuffleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 26,
        onPressed: _onButtonPress,
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

  void _onButtonPress() {
    _appState.shuffleNotifier.value = !_appState.shuffleNotifier.value;
    _mpris.shuffle = _appState.shuffleNotifier.value;
  }
}
