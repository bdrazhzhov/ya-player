import 'package:flutter/material.dart';

import '/controls/playback/repeat_button.dart';
import '/controls/playback/shuffle_button.dart';
import '/controls/sliver_track_list.dart';
import '/controls/track_list/sliver_tracks_header.dart';
import '/models/music_api/track.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class QueuePage extends StatefulWidget {
  QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  final _appState = getIt<AppState>();

  @override
  void initState() {
    super.initState();
    _appState.isQueueShown = true;
  }

  @override
  void dispose() {
    _appState.isQueueShown = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageBase(
      scrollItemHeight: 58,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 20),
            child: Row(
              children: [
                Expanded(child: Text('Playback queue', style: theme.textTheme.displayMedium)),
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
            return SliverTrackList(playContext: _appState.playContext, tracks: tracks);
          },
        ),
      ],
    );
  }
}
