import 'package:flutter/material.dart';

import 'page_base.dart';
import '/services/app_state.dart';
import '/controls/playback/repeat_button.dart';
import '/controls/playback/shuffle_button.dart';
import '/controls/sliver_track_list.dart';
import '/controls/track_list/sliver_tracks_header.dart';
import '/models/music_api/track.dart';
import '/services/service_locator.dart';

class QueuePage extends StatelessWidget {
  final _appState = getIt<AppState>();

  QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageBase(slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Playback queue',
                  style: theme.textTheme.displayMedium
                )
              ),
              RepeatButton(),
              ShuffleButton()
            ],
          ),
        ),
      ),
      SliverPersistentHeader(
        delegate: SliverTracksHeader(),
        pinned: true,
      ),
      ValueListenableBuilder(
        valueListenable: _appState.queueTracks,
        builder: (_, List<Track> tracks, __) {
          return SliverTrackList(tracks: tracks);
        },
      ),
    ]);
  }
}
