import 'package:flutter/material.dart';

import '/app_state.dart';
import '/services/service_locator.dart';

class VolumeControl extends StatelessWidget {
  final _appState = getIt<AppState>();

  VolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appState.volumeNotifier,
      builder: (_, value, __) {
        return Slider(
          value: value,
          onChanged: (double value) => _appState.volumeNotifier.value = value,
        );
      }
    );
  }
}
