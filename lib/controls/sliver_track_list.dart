import 'package:flutter/material.dart';

import '/models/music_api/can_be_played.dart';
import 'track_list/track_list_item.dart';
import '/app_state.dart';
import '/notifiers/play_button_notifier.dart';
import '/player/players_manager.dart';
import '/services/service_locator.dart';

class SliverTrackList extends StatefulWidget {
  final List<CanBePlayed> tracks;
  final bool albumMode;
  final Future<void> Function(int? index)? onBeforeStartPlaying;

  const SliverTrackList({
    super.key,
    required this.tracks,
    this.albumMode = false,
    this.onBeforeStartPlaying
  });

  @override
  State<SliverTrackList> createState() => _SliverTrackListState();
}

class _SliverTrackListState extends State<SliverTrackList> {
  final appState = getIt<AppState>();
  final player = getIt<PlayersManager>();
  bool isPlayingStarted = false;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.tracks.length,
      itemBuilder: (BuildContext context, int index) {
        CanBePlayed track = widget.tracks[index];

        return ValueListenableBuilder(
          valueListenable: appState.trackNotifier,
          builder: (_, CanBePlayed? currentTrack, __) {
            return ValueListenableBuilder(
              valueListenable: appState.playButtonNotifier,
              builder: (___, ButtonState value, ____) {
                bool isPlaying = value == ButtonState.playing;
                bool isCurrent = currentTrack != null && currentTrack == track;

                return TrackListItem(
                  track: track,
                  isPlaying: isPlaying,
                  isCurrent: isCurrent,
                  trackIndex: index,
                  showTrackNumber: widget.albumMode,
                  showAlbum: !widget.albumMode,
                  showArtistName: !widget.albumMode,
                  onTap: () async {
                    if(!track.isAvailable) return;
                    if(!isPlayingStarted) {
                      isPlayingStarted = true;
                      if(widget.onBeforeStartPlaying != null) {
                        await widget.onBeforeStartPlaying!(index);
                      }
                    }

                    if(isPlaying && isCurrent) {
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
    );
  }
}
