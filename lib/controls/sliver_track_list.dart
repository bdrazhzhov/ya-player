import 'package:flutter/material.dart';

import '/models/music_api/track.dart';
import '/helpers/multi_value_listenable_builder.dart';
import '/services/player_state.dart';
import 'track_list/track_list_item.dart';
import '/services/app_state.dart';
import '/player/player.dart';
import '/services/service_locator.dart';

class SliverTrackList extends StatefulWidget {
  final Object playContext;
  final List<Track> tracks;
  final bool albumMode;

  const SliverTrackList({
    super.key,
    required this.playContext,
    required this.tracks,
    this.albumMode = false,
  });

  @override
  State<SliverTrackList> createState() => _SliverTrackListState();
}

class _SliverTrackListState extends State<SliverTrackList> {
  final appState = getIt<AppState>();
  final playerState = getIt<PlayerState>();
  bool isPlayingStarted = false;
  bool isQueueLoaded = false;
  int currentIndex = -1;
  static Object? playContext;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.tracks.length,
      itemBuilder: (BuildContext context, int index) {
        Track track = widget.tracks[index];

        return MultiValueListenableBuilder(
          valuesListenable: [appState.trackNotifier, playerState.playBackStateNotifier],
          builder: (BuildContext context, List<ValueNotifier<dynamic>> values, Widget? child) {
            bool isPlaying = values.get<PlayBackState>() == PlayBackState.playing;
            bool isCurrent = values.get<Track?>() == track;

            return TrackListItem(
              track: track,
              isPlaying: isPlaying,
              isCurrent: isCurrent,
              trackIndex: index,
              showTrackNumber: widget.albumMode,
              showAlbum: !widget.albumMode,
              showArtistName: !widget.albumMode,
              onTap: () async {
                if (!track.isAvailable) return;

                if(playContext != widget.playContext) {
                  playContext = widget.playContext;
                  appState.playContent(playContext!, widget.tracks, index);
                  return;
                }

                getIt<Player>().playPauseByIndex(index);
              },
            );
          },
        );
      },
    );
  }
}
