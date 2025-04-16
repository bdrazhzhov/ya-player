import 'package:flutter/material.dart';

import '/player_state.dart';
import 'artist/artist_names.dart';
import '/models/music_api/track.dart';
import '/services/service_locator.dart';
import 'track_title.dart';

class TrackName extends StatelessWidget {
  TrackName({super.key,});

  final _playerState = getIt<PlayerState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _playerState.trackNotifier,
        builder: (_, Track? track, __) {
          if(track != null) {
            return Container(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: TrackTitle(track: track),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: ArtistNames(artists: track.artists),
                  )
                ]
              ),
            );
          }
          else {
            return const SizedBox(width: 1, height: 1);
          }
        }
    );
  }
}
