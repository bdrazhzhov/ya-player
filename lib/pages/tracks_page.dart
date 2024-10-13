import 'package:flutter/material.dart';

import '/player/tracks_source.dart';
import '/player/players_manager.dart';
import '/app_state.dart';
import '/models/music_api/track.dart';
import '/services/service_locator.dart';
import '/controls/sliver_track_list.dart';
import '/controls/track_list/sliver_tracks_header.dart';
import 'page_base.dart';

class TracksPage extends StatelessWidget {
  final _appState = getIt<AppState>();
  final _player = getIt<PlayersManager>();

  TracksPage({super.key}) {
    _player.currentPageTracksSourceData = TracksSource(
      sourceType: TracksSourceType.likedTracks,
      source: _appState.likedTracksNotifier.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return PageBase(
      title: 'Tracks',
      slivers: [
        SliverPersistentHeader(
          delegate: SliverTracksHeader(),
          pinned: true,
        ),
        ValueListenableBuilder<List<Track>>(
          valueListenable: appState.likedTracksNotifier,
          builder: (_, tracks, __) => SliverTrackList(tracks: tracks)
        )
      ]
    );
  }
}
