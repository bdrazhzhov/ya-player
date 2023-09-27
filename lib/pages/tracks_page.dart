import 'package:flutter/material.dart';
import 'package:ya_player/app_state.dart';
import 'package:ya_player/models/music_api/track.dart';
import 'package:ya_player/services/service_locator.dart';

import '../controls/sliver_track_list.dart';
import '../controls/track_list/sliver_tracks_header.dart';
import '../helpers/playback_queue.dart';
import 'page_base.dart';

class TracksPage extends StatelessWidget {
  const TracksPage({super.key});

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
          builder: (_, tracks, __) => SliverTrackList(tracks: tracks, queueName: QueueNames.trackList)
        )
      ]
    );
  }
}
