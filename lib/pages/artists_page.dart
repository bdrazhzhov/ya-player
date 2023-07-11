import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/artist.dart';

import '../app_state.dart';
import '../music_api.dart';
import '../services/service_locator.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Artists'),
          ValueListenableBuilder<List<LikedArtist>>(
              valueListenable: appState.artistsNotifier,
              builder: (_, artists, __) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: artists.map((artist) => _ArtistCard(artist)).toList(),
                );
              }
          ),
        ],
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final LikedArtist artist;

  const _ArtistCard(this.artist);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ClipOval(
          child: CachedNetworkImage(
              width: 200,
              height: 200,
              imageUrl: MusicApi.imageUrl(artist.ogImage, '600x600').toString()
          ),
        ),
        Text(artist.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          "${artist.counts.tracks} tracks",
          style: TextStyle(fontSize: theme.textTheme.labelMedium?.fontSize),
        ),
        Text(
          artist.genres.map((e) => '${e[0].toUpperCase()}${e.substring(1)}').join(', '),
          style: TextStyle(fontSize: theme.textTheme.labelMedium?.fontSize),
        )
      ],
    );
  }
}
