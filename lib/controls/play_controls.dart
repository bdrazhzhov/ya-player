import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ya_player/services/service_locator.dart';

import '../app_state.dart';
import 'play_button.dart';

class PlayControls extends StatelessWidget {
  PlayControls({super.key,});

  final AppState _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _appState.previous,
          icon: const FaIcon(FontAwesomeIcons.backwardStep),
          iconSize: 20,
        ),
        PlayButton(),
        IconButton(
          onPressed: _appState.next,
          icon: const FaIcon(FontAwesomeIcons.forwardStep),
          iconSize: 20,
        ),
      ],
    );
  }
}
