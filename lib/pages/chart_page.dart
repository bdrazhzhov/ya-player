import 'package:flutter/material.dart';

import '/controls/similar_playlists.dart';
import '/app_state.dart';
import '/controls/page_loading_indicator.dart';
import '/controls/playlist_flexible_space.dart';
import '/controls/sliver_track_list.dart';
import '/models/music_api_types.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class ChartPage extends StatelessWidget {
  late final Future<Playlist> _playlistData = _musicApi.chart();
  final _appState = getIt<AppState>();
  final _musicApi = getIt<MusicApi>();

  ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Playlist>(
      future: _playlistData,
      builder: (_, AsyncSnapshot<Playlist> snapshot){
        if(snapshot.hasData) {
          final Playlist playlist = snapshot.data!;

          return PageBase(
            flexibleSpace: PlaylistFlexibleSpace(playlist: playlist),
            slivers: [
              SliverTrackList(
                tracks: snapshot.data!.tracks,
                onBeforeStartPlaying: (int? index) =>
                    _appState.playContent(playlist, playlist.tracks, index)
              ),
              if(playlist.similarPlaylists.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.only(top: 36),
                  sliver: SliverToBoxAdapter(
                    child: SimilarPlaylists(playlists: playlist.similarPlaylists)
                  )
                )
            ],
          );
        }
        else {
          return PageLoadingIndicator();
        }
      }
    );
  }
}
