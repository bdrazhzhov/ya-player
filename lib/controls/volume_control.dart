import 'package:flutter/material.dart';

import '/player_state.dart';
import '/services/service_locator.dart';

class VolumeControl extends StatelessWidget {
  final _playerState = getIt<PlayerState>();

  VolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _playerState.volumeNotifier,
      builder: (_, value, __) {
        return Slider(
          value: value,
          onChanged: (double value) => _playerState.volumeNotifier.value = value,
        );
      }
    );
  }
}
