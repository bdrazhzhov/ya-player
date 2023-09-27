import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/artist.dart';
import 'package:ya_player/pages/page_base.dart';

import '../app_state.dart';
import '../controls/artist_card.dart';
import '../services/service_locator.dart';

class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return PageBase(
      title: 'Artists',
      slivers: [ValueListenableBuilder<List<LikedArtist>>(
        valueListenable: appState.artistsNotifier,
        builder: (_, artists, __) {
          return SliverToBoxAdapter(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: artists.map((artist) => ArtistCard(artist, 200)).toList(),
            ),
          );
        }
      )]
    );
  }
}
