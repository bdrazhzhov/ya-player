import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/artist.dart';

import '../app_state.dart';
import '../controls/artist_card.dart';
import '../services/service_locator.dart';

class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();
    final size = MediaQuery.of(context).size;
    double width = size.width / 3;
    if(width < 130) {
      width = 130;
    } else if(width > 200) {
      width = 200;
    }

    return SingleChildScrollView(
      child: ValueListenableBuilder<List<LikedArtist>>(
          valueListenable: appState.artistsNotifier,
          builder: (_, artists, __) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: artists.map((artist) => ArtistCard(artist, width)).toList(),
            );
          }
      ),
    );
  }
}
