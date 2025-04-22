import 'package:flutter/material.dart';

import '/services/player_state.dart';
import '/services/state_enums.dart';
import '/services/service_locator.dart';

class RepeatButton extends StatelessWidget {
  final _playerState = getIt<PlayerState>();

  RepeatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _playerState.canRepeatNotifier,
      builder: (BuildContext context, isEnabled, Widget? child) {
        return IconButton(
          iconSize: 26,
          onPressed: isEnabled ? _onButtonPress : null,
          icon: ValueListenableBuilder<RepeatMode>(
            valueListenable: _playerState.repeatNotifier,
            builder: (_, RepeatMode repeatMode, __) {
              switch(repeatMode) {
                case RepeatMode.on:
                  return const Icon(Icons.repeat_on_outlined);
                case RepeatMode.one:
                  return const Icon(Icons.repeat_one_on_outlined);
                case RepeatMode.off:
                  return const Icon(Icons.repeat_outlined);
              }
            }
          )
        );
      }
    );
  }

  void _onButtonPress() {
    switch(_playerState.repeatNotifier.value) {
      case RepeatMode.on:
        _playerState.repeatNotifier.value = RepeatMode.one;
      case RepeatMode.one:
        _playerState.repeatNotifier.value = RepeatMode.off;
      case RepeatMode.off:
        _playerState.repeatNotifier.value = RepeatMode.on;
    }
  }
}
