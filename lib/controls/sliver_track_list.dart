import 'package:flutter/material.dart';
import 'package:ya_player/controls/track_list/track_list_item.dart';

import '../app_state.dart';
import '../models/music_api/track.dart';
import '../notifiers/play_button_notifier.dart';
import '../services/service_locator.dart';

class SliverTrackList extends StatefulWidget {
  final List<Track> tracks;
  final String queueName;
  final bool showAlbum;

  const SliverTrackList({
    super.key,
    required this.tracks,
    required this.queueName,
    this.showAlbum = true,
  });

  @override
  State<SliverTrackList> createState() => _SliverTrackListState();
}

class _SliverTrackListState extends State<SliverTrackList> {
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.tracks.length,
      itemBuilder: (BuildContext context, int index) {
        Track track = widget.tracks[index];

        return ValueListenableBuilder(
          valueListenable: appState.trackNotifier,
          builder: (_, Track? currentTrack, __) {
            return ValueListenableBuilder(
              valueListenable: appState.playButtonNotifier,
              builder: (___, ButtonState value, ____) {
                bool isPlaying = value == ButtonState.playing;
                bool isCurrent = currentTrack != null && currentTrack == track;

                return TrackListItem(
                  track: track,
                  isPlaying: isPlaying,
                  isCurrent: isCurrent,
                  onTap: (){
                    if(!track.isAvailable) return;

                    if(isPlaying && isCurrent) {
                      appState.pause();
                    } else {
                      appState.playTracks(widget.tracks, index, widget.queueName);
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
