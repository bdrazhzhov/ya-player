import 'package:flutter/material.dart';
import 'package:ya_player/app_state.dart';
import 'package:ya_player/models/music_api/track.dart';
import 'package:ya_player/services/service_locator.dart';

import '../controls/track_list.dart';
import '../controls/page_base_layout.dart';

class TracksPage extends StatefulWidget {
  const TracksPage({super.key});

  @override
  State<TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return PageBaseLayout(
      title: 'Tracks',
      body: SingleChildScrollView(
        child: ValueListenableBuilder<List<Track>>(
          valueListenable: appState.likedTracksNotifier,
          builder: (_, tracks, __) => TrackList(tracks, showAlbum: true)
        ),
      ),
    );
  }
}
