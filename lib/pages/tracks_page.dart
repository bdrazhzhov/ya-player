import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/services/app_state.dart';
import '/models/music_api/track.dart';
import '/services/service_locator.dart';
import '/controls/sliver_track_list.dart';
import '/controls/track_list/sliver_tracks_header.dart';
import 'page_base.dart';

class TracksPage extends StatelessWidget {
  final _appState = getIt<AppState>();
  final List<Track> _context = [];

  TracksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBase(
      title: AppLocalizations.of(context)!.page_tracks,
      slivers: [
        SliverPersistentHeader(
          delegate: SliverTracksHeader(),
          pinned: true,
        ),
        ValueListenableBuilder<List<Track>>(
          valueListenable: _appState.likedTracksNotifier,
          builder: (_, tracks, __) => SliverTrackList(
            playContext: _context,
            tracks: tracks,
          )
        )
      ]
    );
  }
}
