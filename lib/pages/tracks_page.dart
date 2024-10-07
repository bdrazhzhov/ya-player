import 'package:flutter/material.dart';

import '/app_state.dart';
import '/models/music_api/track.dart';
import '/player/liked_tracks_player.dart';
import '/services/service_locator.dart';
import '/controls/sliver_track_list.dart';
import '/controls/track_list/sliver_tracks_header.dart';
import 'page_base.dart';

class TracksPage extends StatefulWidget {

  const TracksPage({super.key});

  @override
  State<TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  final player = LikedTracksPlayer();
  final _appState = getIt<AppState>();

  @override
  void initState() {
    super.initState();
    _appState.playerEventsStream.listen((PlayerEvent event){
      switch(event) {
        case PlayerEvent.play:
          // TODO: Handle this case.
        case PlayerEvent.next:
          player.next();
        case PlayerEvent.previous:
          player.previous();
      }
    });
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
          builder: (_, tracks, __) => SliverTrackList(tracks: tracks, player: player)
        )
      ]
    );
  }
}
