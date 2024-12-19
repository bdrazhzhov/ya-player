import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/app_state.dart';
import '/player/players_manager.dart';
import '/services/service_locator.dart';

class PreviousButton extends StatelessWidget {
  final _playersManager = getIt<PlayersManager>();
  final _appState = getIt<AppState>();

  PreviousButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _appState.canGoPreviousNotifier,
      builder: (_, isEnabled, __) {
        return IconButton(
          onPressed: isEnabled ? () { _playersManager.previous(); } : null,
          icon: const FaIcon(FontAwesomeIcons.backwardStep),
          iconSize: 20,
        );
      },
    );
  }
}
