import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '/models/music_api/playlist.dart';
import '/models/music_api/track.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'track_list/track_list_item.dart';

class SliverTrackList extends StatelessWidget {
  final Equatable playContext;
  final List<Track> tracks;
  final bool albumMode;

  final appState = getIt<AppState>();
  final playerState = getIt<PlayerState>();

  SliverTrackList({
    super.key,
    required this.playContext,
    required this.tracks,
    this.albumMode = false,
  });

  @override
  Widget build(BuildContext context) {
    itemBuilder(BuildContext context, int index) {
      Track track = tracks[index];

      return TrackListItem(
        track: track,
        trackIndex: index,
        showTrackNumber: albumMode,
        showAlbum: !albumMode,
        showArtistName: !albumMode,
        playContext: playContext,
        tracks: tracks,
      );
    }

    if (playContext is Playlist) {
      var playlist = playContext as Playlist;

      if (appState.isPlaylistEditable(playlist)) {
        return SliverReorderableList(
          itemCount: tracks.length,
          itemBuilder: (BuildContext context, int index) {
            return ReorderableDragStartListener(
              key: ValueKey(tracks[index].id),
              index: index,
              child: itemBuilder(context, index),
            );
          },
          itemExtent: 58.0,
          onReorder: (int oldIndex, int newIndex) async {
            if (oldIndex < newIndex) newIndex -= 1;

            final track = tracks[oldIndex];
            final item = tracks.removeAt(oldIndex);
            tracks.insert(newIndex, item);

            playlist =
                await getIt<MusicApi>().movePlaylistTracks(playlist, [track], oldIndex, newIndex);
            getIt<AppState>().requestPlaylists();
          },
        );
      }
    }

    return SliverList.builder(
      itemCount: tracks.length,
      itemBuilder: itemBuilder,
    );
  }
}
