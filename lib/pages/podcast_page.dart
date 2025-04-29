import 'package:flutter/material.dart';

import '/controls/album_flexible_space.dart';
import '/controls/tracks_header.dart';
import '/services/app_state.dart';
import '/controls/page_loading_indicator.dart';
import '/controls/sliver_track_list.dart';
import '/models/music_api_types.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PodcastPage extends StatelessWidget {
  final Podcast podcast;
  late final Future<AlbumWithTracks> _albumWidthTracks;
  final _musicApi = getIt<MusicApi>();

  PodcastPage(this.podcast, {super.key}) {
    _albumWidthTracks = _musicApi.albumWithTracks(podcast.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AlbumWithTracks>(
      future: _albumWidthTracks,
      builder: (BuildContext context, AsyncSnapshot<AlbumWithTracks> snapshot){
        if(snapshot.hasData)
        {
          final albumWithTracks = snapshot.data!;
          return PageBase(
            flexibleSpace: AlbumFlexibleSpace(album: albumWithTracks.album),
            slivers: [
              SliverPersistentHeader(
                delegate: TracksHeader(),
                pinned: true,
              ),

              SliverTrackList(
                playContext: podcast,
                tracks: albumWithTracks.tracks,
                albumMode: true,
              ),
            ],
          );
        }
        else
        {
          return const PageLoadingIndicator();
        }
      }
    );
  }
}
