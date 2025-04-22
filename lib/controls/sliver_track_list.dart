import 'package:flutter/material.dart';

import '/helpers/multi_value_listenable_builder.dart';
import '/services/player_state.dart';
import '/models/music_api/can_be_played.dart';
import 'track_list/track_list_item.dart';
import '/services/app_state.dart';
import '/player/players_manager.dart';
import '/services/service_locator.dart';

class SliverTrackList extends StatefulWidget {
  final List<CanBePlayed> tracks;
  final bool albumMode;
  final Future<void> Function(int? index)? onBeforeStartPlaying;

  const SliverTrackList(
      {super.key, required this.tracks, this.albumMode = false, this.onBeforeStartPlaying});

  @override
  State<SliverTrackList> createState() => _SliverTrackListState();
}

class _SliverTrackListState extends State<SliverTrackList> {
  final appState = getIt<AppState>();
  final playerState = getIt<PlayerState>();
  final player = getIt<PlayersManager>();
  bool isPlayingStarted = false;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.tracks.length,
      itemBuilder: (BuildContext context, int index) {
        CanBePlayed track = widget.tracks[index];

        return MultiValueListenableBuilder(
          valuesListenable: [playerState.trackNotifier, playerState.playBackStateNotifier],
          builder: (BuildContext context, List<ValueNotifier<dynamic>> values, Widget? child) {
            bool isPlaying = values.get<PlayBackState>() == PlayBackState.playing;
            bool isCurrent = values.get<CanBePlayed?>() == track;

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
                if (!isPlayingStarted) {
                  isPlayingStarted = true;
                  if (widget.onBeforeStartPlaying != null) {
                    await widget.onBeforeStartPlaying!(index);
                  }
                }

                if (isPlaying && isCurrent) {
                  player.pause();
                } else {
                  player.play(index);
                }
              },
            );
          },
        );
      },
    );
  }
}
