import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/services/service_locator.dart';
import '/player/players_manager.dart';
import 'play_button.dart';

class PlayControls extends StatelessWidget {
  PlayControls({super.key,});

  final _player = getIt<PlayersManager>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () { _player.previous(); },
          icon: const FaIcon(FontAwesomeIcons.backwardStep),
          iconSize: 20,
        ),
        PlayButton(),
        IconButton(
          onPressed: () { _player.next(); },
          icon: const FaIcon(FontAwesomeIcons.forwardStep),
          iconSize: 20,
        ),
      ],
    );
  }
}
