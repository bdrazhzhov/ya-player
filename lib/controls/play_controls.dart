import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/app_state.dart';
import '/services/service_locator.dart';
import '/player/players_manager.dart';
import 'play_button.dart';
import 'repeat_button.dart';
import 'shuffle_button.dart';

class PlayControls extends StatelessWidget {
  PlayControls({super.key,});

  final _playersManager = getIt<PlayersManager>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () { _playersManager.previous(); },
          icon: const FaIcon(FontAwesomeIcons.backwardStep),
          iconSize: 20,
        ),
        PlayButton(),
        IconButton(
          onPressed: () { _playersManager.next(); },
          icon: const FaIcon(FontAwesomeIcons.forwardStep),
          iconSize: 20,
        ),
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
      builder: (_, value, Widget? child) {
        if(value == null) {
          return child!;

        }

        return SizedBox.shrink();
      },
      child: Row(children: [
        RepeatButton(),
        ShuffleButton()
      ]),
    );
  }
}

