import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_state.dart';
import 'play_button.dart';

class PlayControls extends StatelessWidget {
  const PlayControls({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: appState.previous,
          icon: const FaIcon(FontAwesomeIcons.backwardStep),
          iconSize: 20,
        ),
        PlayButton(appState: appState),
        IconButton(
          onPressed: appState.next,
          icon: const FaIcon(FontAwesomeIcons.forwardStep),
          iconSize: 20,
        ),
      ],
    );
  }
}
