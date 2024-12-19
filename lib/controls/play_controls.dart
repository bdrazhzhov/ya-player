import 'package:flutter/material.dart';

import 'playback/next_button.dart';
import 'playback/previous_button.dart';
import '/app_state.dart';
import '/services/service_locator.dart';
import 'play_button.dart';
import 'playback/repeat_button.dart';
import 'playback/shuffle_button.dart';
import 'station_settings_button.dart';

class PlayControls extends StatelessWidget {
  const PlayControls({super.key,});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PreviousButton(),
        PlayButton(),
        NextButton(),
        _RepeatShuffle()
      ],
    );
  }
}

class _RepeatShuffle extends StatelessWidget {
  final _appState = getIt<AppState>();

  _RepeatShuffle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appState.currentStationNotifier,
      builder: (_, value, __) {
        if(value == null) {
          return Row(children: [
            RepeatButton(),
            ShuffleButton()
          ]);
        }

        return StationSettingsButton(station: _appState.currentStationNotifier.value!);
      },
    );
  }
}

