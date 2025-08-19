import 'package:flutter/material.dart';

import '/services/music_api.dart';
import '/models/music_api/playlist.dart';
import '/models/music_api/track.dart';
import '/helpers/multi_value_listenable_builder.dart';
import '/services/player_state.dart';
import 'track_list/track_list_item.dart';
import '/services/app_state.dart';
import '/player/player.dart';
import '/services/service_locator.dart';

class SliverTrackList extends StatelessWidget {
  final Object playContext;
  final List<Track> tracks;
  final bool albumMode;

  final appState = getIt<AppState>();
  final playerState = getIt<PlayerState>();
  late final availableTracks = tracks.where((t) => t.isAvailable).toList();
  bool isPlayingStarted = false;
  bool isQueueLoaded = false;
  int currentIndex = -1;
  static Object? prevPlayContext;

  SliverTrackList({
    super.key,
    required this.playContext,
    required this.tracks,
    this.albumMode = false,
  });

  @override
  Widget build(BuildContext context) {
    itemBuilder(BuildContext context, int index) {
      Track track = availableTracks[index];

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
            showTrackNumber: albumMode,
            showAlbum: !albumMode,
            showArtistName: !albumMode,
            playContext: playContext,
            onTap: () async {
              if(prevPlayContext != playContext) {
                prevPlayContext = playContext;

                appState.playContent(playContext, availableTracks, index);
                return;
              }

              getIt<Player>().playPauseByIndex(index);
            },
          );
        },
      );
    }

    if(playContext is Playlist) {
      var playlist = playContext as Playlist;

      if(appState.isPlaylistEditable(playlist)) {
        return SliverReorderableList(
          itemCount: availableTracks.length,
          itemBuilder: (BuildContext context, int index) {
            return ReorderableDragStartListener(
              key: ValueKey(availableTracks[index].id),
              index: index,
              child: itemBuilder(context, index),
            );
          },
          itemExtent: 58.0,
          onReorder: (int oldIndex, int newIndex) async {
            // print('Reordering track from $oldIndex to $newIndex');
            if (oldIndex < newIndex) newIndex -= 1;

            final track = availableTracks[oldIndex];
            final item = availableTracks.removeAt(oldIndex);
            availableTracks.insert(newIndex, item);

            playlist = await getIt<MusicApi>().movePlaylistTracks(
                playlist, [track], oldIndex, newIndex);
            getIt<AppState>().requestPlaylists();
          },
        );
      }
    }

    return SliverList.builder(
      itemCount: availableTracks.length,
      itemBuilder: itemBuilder,
    );
  }
}
