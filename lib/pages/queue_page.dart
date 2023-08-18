import 'package:flutter/material.dart';
import '../app_state.dart';
import '../controls/sliver_track_list.dart';
import '../controls/track_list/sliver_tracks_header.dart';
import '../models/music_api/track.dart';
import '../services/service_locator.dart';

class QueuePage extends StatelessWidget {
  final String queueName;
  final _appState = getIt<AppState>();

  QueuePage({super.key, required this.queueName});

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
              child: Row(
                children: [
                  Expanded(child: Text('Playback queue', style: theme.textTheme.displayMedium)),
                  IconButton(onPressed: (){}, icon: const Icon(Icons.repeat)),
                  IconButton(onPressed: (){}, icon: const Icon(Icons.shuffle))
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 32, right: 32),
          sliver: SliverPersistentHeader(
            delegate: SliverTracksHeader(),
            pinned: true,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _appState.queueTracks,
          builder: (_, List<Track> tracks, __) {
            return SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32),
              sliver: SliverTrackList(tracks: tracks, queueName: queueName)
            );
          },
        ),
      ],
    );
  }
}
