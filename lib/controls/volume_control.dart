import 'package:flutter/material.dart';

import '/services/audio_player.dart';
import '/services/service_locator.dart';

class VolumeControl extends StatelessWidget {
  final _audioPlayer = getIt<AudioPlayer>();

  VolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _audioPlayer.volumeNotifier,
      builder: (_, value, __) {
        return Slider(
          value: value,
          onChanged: (double value) => _audioPlayer.volumeNotifier.value = value,
        );
      }
    );
  }
}
