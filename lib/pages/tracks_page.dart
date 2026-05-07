import 'dart:async';

import 'package:flutter/material.dart';

import '/controls/page_loading_indicator.dart';
import '/controls/sliver_track_list.dart';
import '/controls/track_list/sliver_tracks_header.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/playlist.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class TracksPage extends StatelessWidget {
  late final Future<Playlist> _playlistData =
      getIt<MusicApi>().likedTracksPlaylist();
  final _dataLoadedFuture = Completer();

  TracksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBase(
      scrollItemHeight: 58,
      onScrollPrepare: _dataLoadedFuture.future,
      title: AppLocalizations.of(context)!.page_tracks,
      slivers: [
        SliverPersistentHeader(
          delegate: SliverTracksHeader(),
          pinned: true,
        ),
        FutureBuilder<Playlist>(
          future: _playlistData,
          builder: (_, AsyncSnapshot<Playlist> snapshot) {
            if (snapshot.hasData) {
              if (!_dataLoadedFuture.isCompleted) _dataLoadedFuture.complete();

              final tracks =
                  snapshot.data!.tracks.where((t) => t.isAvailable).toList();
              return SliverTrackList(
                playContext: snapshot.data!,
                tracks: tracks,
              );
            } else {
              return const SliverToBoxAdapter(child: PageLoadingIndicator());
            }
          },
        ),
      ],
    );
  }
}
