import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/services/player_state.dart';
import '/player/player.dart';
import '/services/service_locator.dart';

class PreviousButton extends StatelessWidget {
  final _playerState = getIt<PlayerState>();

  PreviousButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _playerState.canPrevNotifier,
      builder: (_, isEnabled, __) {
        return IconButton(
          onPressed: isEnabled ? () { getIt<Player>().previous(); } : null,
          icon: const FaIcon(FontAwesomeIcons.backwardStep),
          iconSize: 20,
        );
      },
    );
  }
}
