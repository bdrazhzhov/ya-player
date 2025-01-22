import 'package:flutter/material.dart';

import '/controls/playlist_flexible_space.dart';
import '/app_state.dart';
import '/controls/sliver_track_list.dart';
import '/music_api.dart';
import '/controls/page_loading_indicator.dart';
import '/models/music_api/playlist.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PlaylistPage extends StatelessWidget {
  final Playlist playlist;
  late final Future<Playlist> _playlistData = _musicApi.playlist(playlist.uid, playlist.kind);
  final _appState = getIt<AppState>();
  final _musicApi = getIt<MusicApi>();

  PlaylistPage(this.playlist, {super.key});

  @override
  Widget build(BuildContext context) {
    return PageBase(
      slivers: [
        SliverAppBar(
          leading: const SizedBox.shrink(),
          pinned: true,
          flexibleSpace: PlaylistFlexibleSpace(playlist: playlist),
          collapsedHeight: 60,
          expandedHeight: 200,
        ),
        FutureBuilder<Playlist>(
          future: _playlistData,
          builder: (_, AsyncSnapshot<Playlist> snapshot){
            if(snapshot.hasData) {
              return SliverTrackList(
                tracks: snapshot.data!.tracks,
                onBeforeStartPlaying: (int? index) =>
                    _appState.playContent(snapshot.data!, snapshot.data!.tracks, index)
              );
            }
            else {
              return const SliverToBoxAdapter(child: PageLoadingIndicator());
            }
          }
        )
      ],
    );
  }
}
