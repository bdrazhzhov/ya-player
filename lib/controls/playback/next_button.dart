import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/services/player_state.dart';
import '/player/player.dart';
import '/services/service_locator.dart';

class NextButton extends StatelessWidget {
  final _playerState = getIt<PlayerState>();

  NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _playerState.canNextNotifier,
      builder: (_, isEnabled, __) {
        return IconButton(
          onPressed: isEnabled ? () { getIt<Player>().next(); } : null,
          icon: const FaIcon(FontAwesomeIcons.forwardStep),
          iconSize: 20,
        );
      },
    );
  }
}
