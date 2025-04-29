import 'package:flutter/material.dart';

import '/controls/playlist_flexible_space.dart';
import '/controls/sliver_track_list.dart';
import '/services/music_api.dart';
import '/controls/page_loading_indicator.dart';
import '/models/music_api/playlist.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PlaylistPage extends StatelessWidget {
  final Playlist playlist;
  late final Future<Playlist> _playlistData = _musicApi.playlist(playlist.uid, playlist.kind);
  final _musicApi = getIt<MusicApi>();

  PlaylistPage(this.playlist, {super.key});

  @override
  Widget build(BuildContext context) {
    return PageBase(
      flexibleSpace: PlaylistFlexibleSpace(playlist: playlist),
      slivers: [
        FutureBuilder<Playlist>(
          future: _playlistData,
          builder: (_, AsyncSnapshot<Playlist> snapshot){
            if(snapshot.hasData) {
              return SliverTrackList(
                playContext: playlist,
                tracks: snapshot.data!.tracks,
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
