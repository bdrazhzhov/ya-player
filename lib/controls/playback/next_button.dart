import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/player_state.dart';
import '/player/players_manager.dart';
import '/services/service_locator.dart';

class NextButton extends StatelessWidget {
  final _playersManager = getIt<PlayersManager>();
  final _playerState = getIt<PlayerState>();

  NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _playerState.canNextNotifier,
      builder: (_, isEnabled, __) {
        return IconButton(
          onPressed: isEnabled ? () { _playersManager.next(); } : null,
          icon: const FaIcon(FontAwesomeIcons.forwardStep),
          iconSize: 20,
        );
      },
    );
  }
}
