import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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
    final size = MediaQuery.of(context).size;
    double width = size.width / 3;
    if(width < 130) {
      width = 130;
    } else if(width > 200) {
      width = 200;
    }

    var crossAxisAlignment = CrossAxisAlignment.start;
    if(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      crossAxisAlignment = CrossAxisAlignment.center;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          const Text('Artists'),
          ValueListenableBuilder<List<LikedArtist>>(
              valueListenable: appState.artistsNotifier,
              builder: (_, artists, __) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: artists.map((artist) => _ArtistCard(artist, width)).toList(),
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
  final double width;

  const _ArtistCard(this.artist, this.width);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
                width: width,
                height: width,
                imageUrl: MusicApi.imageUrl(artist.ogImage, '600x600').toString()
            ),
          ),
          Text(
            artist.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${artist.counts.tracks} tracks",
            style: TextStyle(fontSize: theme.textTheme.labelMedium?.fontSize),
          ),
          Text(
            artist.genres.map((e) => '${e[0].toUpperCase()}${e.substring(1)}').join(', '),
            style: TextStyle(fontSize: theme.textTheme.labelMedium?.fontSize),
          )
        ],
      ),
    );
  }
}
