import 'package:flutter/material.dart';

import '../models/music_api/artist.dart';
import '../pages/artist_page.dart';
import 'yandex_image.dart';

class ArtistCard extends StatelessWidget {
  final LikedArtist artist;
  final double width;

  const ArtistCard(this.artist, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkResponse(
      onTap: () {
        Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ArtistPage(artist),
              reverseTransitionDuration: Duration.zero,
            )
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          children: [
            if(artist.cover != null)
              YandexImage(
                uriPlaceholder: artist.cover!.uri,
                size: width,
                borderRadius: 8
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
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            )
          ],
        ),
      ),
    );
  }
}
