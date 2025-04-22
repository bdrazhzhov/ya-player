import 'package:flutter/material.dart';

import '/models/music_api/track.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';

class PlayPauseButton extends StatelessWidget {
  static const buttonColor = Color.fromARGB(255, 255, 219, 77);
  final Track track;
  final double size;

  PlayPauseButton({super.key, required this.track, required this.size});

  final _playerState = getIt<PlayerState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      ),
      child: ValueListenableBuilder(
        valueListenable: _playerState.playBackStateNotifier,
        builder: (_, PlayBackState stateValue, __) {
          if(stateValue != PlayBackState.playing) {
            return const Icon(Icons.play_arrow, color: Colors.black);
          }

          return ValueListenableBuilder(
            valueListenable: _playerState.trackNotifier,
            builder: (___, Track? currentTrack, Widget? ____) {
              if(currentTrack == track) {
                return const Icon(Icons.pause, color: Colors.black);
              } else {
                return const Icon(Icons.play_arrow, color: Colors.black);
              }
            },
          );
        },
      ),
    );
  }
}
