import 'package:flutter/material.dart';

import '/dbus/mpris/mpris_player.dart';
import '/state_enums.dart';
import '/app_state.dart';
import '/services/service_locator.dart';

class RepeatButton extends StatelessWidget {
  final _appState = getIt<AppState>();
  final _mpris = getIt<OrgMprisMediaPlayer2>();

  RepeatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appState.canRepeatNotifier,
      builder: (BuildContext context, isEnabled, Widget? child) {
        return IconButton(
          iconSize: 26,
          onPressed: isEnabled ? _onButtonPress : null,
          icon: ValueListenableBuilder<RepeatMode>(
            valueListenable: _appState.repeatNotifier,
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
    switch(_appState.repeatNotifier.value) {
      case RepeatMode.on:
        _appState.repeatNotifier.value = RepeatMode.one;
      case RepeatMode.one:
        _appState.repeatNotifier.value = RepeatMode.off;
      case RepeatMode.off:
        _appState.repeatNotifier.value = RepeatMode.on;
    }

    _mpris.repeat = _appState.repeatNotifier.value;
  }
}
