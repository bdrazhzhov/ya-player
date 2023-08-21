import 'package:flutter/material.dart';

import '../app_state.dart';
import '../controls/sliver_track_list.dart';
import '../controls/slivers_container.dart';
import '../controls/track_list/sliver_tracks_header.dart';
import '../helpers/playback_queue.dart';
import '../models/music_api_types.dart';
import '../services/service_locator.dart';

class PopularArtistTracks extends StatelessWidget {
  final LikedArtist artist;
  late final Future<List<Track>> _tracks;
  final _appState = getIt<AppState>();

  PopularArtistTracks(this.artist, {super.key}) {
    _tracks = _appState.popularTracks(artist.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliversContainer(
      slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 56),
          child: Text(artist.name, style: theme.textTheme.displayMedium),
        )),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text('All tracks', style: theme.textTheme.titleLarge),
          )
        ),
        SliverPersistentHeader(
          delegate: SliverTracksHeader(),
          pinned: true,
        ),
        FutureBuilder(
          future: _tracks,
          builder: (_, AsyncSnapshot<List<Track>> snapshot) {
            if(snapshot.hasData) {
              return SliverTrackList(
                  tracks: snapshot.data!,
                  showAlbum: true,
                  queueName: QueueNames.artist
              );
            } else {
              return const SliverToBoxAdapter(child: CircularProgressIndicator());
            }
          },
        )
      ],
    );
  }
}
