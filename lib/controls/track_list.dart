import 'package:flutter/material.dart';

import '/services/app_state.dart';
import '/player/playback_queue.dart';
import '/helpers/multi_value_listenable_builder.dart';
import '/player/player.dart';
import '/models/music_api/track.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'track_list/track_list_item.dart';

class TrackList extends StatelessWidget {
  final List<Track> tracks;
  final bool showAlbum;
  final int startIndex;

  TrackList(
    this.tracks, {
    super.key,
    this.showAlbum = false,
    required this.startIndex,
  });

  final _playerState = getIt<PlayerState>();
  final _appState = getIt<AppState>();
  bool isQueueLoaded = false;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    tracks.skip(startIndex).take(5).toList().asMap().forEach((index, track) {
      index += startIndex;

      children.add(
        MultiValueListenableBuilder(
          valuesListenable: [_appState.trackNotifier, _playerState.playBackStateNotifier],
          builder: (BuildContext context, List<ValueNotifier<dynamic>> values, Widget? child) {
            bool isPlaying = values.get<PlayBackState>() == PlayBackState.playing;
            bool isCurrent = values.get<Track?>() == track;

            return TrackListItem(
              track: track,
              isPlaying: isPlaying,
              isCurrent: isCurrent,
              trackIndex: index,
              showTrackNumber: false,
              showAlbum: showAlbum,
              showArtistName: false,
              onTap: () async {
                if (!track.isAvailable) return;

                final queue = getIt<PlaybackQueue>();
                if(!isQueueLoaded) {
                  queue.replaceTracks(tracks);
                  queue.moveTo(index);
                  isQueueLoaded = true;
                }

                getIt<Player>().playPause();
              },
            );
          },
        ),
      );
    });

    return Column(children: children);
  }
}
