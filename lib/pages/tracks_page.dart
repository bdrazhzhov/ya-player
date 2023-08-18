import 'package:flutter/material.dart';
import 'package:ya_player/app_state.dart';
import 'package:ya_player/models/music_api/track.dart';
import 'package:ya_player/services/service_locator.dart';

import '../controls/sliver_track_list.dart';
import '../controls/track_list/sliver_tracks_header.dart';
import '../helpers/playback_queue.dart';

class TracksPage extends StatefulWidget {
  const TracksPage({super.key});

  @override
  State<TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 32, right: 32),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50, top: 65),
              child: Text('Tracks', style: theme.textTheme.displayMedium),
            )
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 32, right: 32),
          sliver: SliverPersistentHeader(
            delegate: SliverTracksHeader(),
            pinned: true,
          ),
        ),
        ValueListenableBuilder<List<Track>>(
          valueListenable: appState.likedTracksNotifier,
          builder: (_, tracks, __) => SliverPadding(
            padding: const EdgeInsets.only(left: 32, right: 32),
            sliver: SliverTrackList(tracks: tracks, queueName: QueueNames.trackList)
          )
        )
      ]
    );
  }
}
