import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/music_api/artist.dart';
import '../music_api.dart';
import '../pages/artist_page.dart';

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
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                  width: width,
                  height: width,
                  imageUrl: MusicApi.imageUrl(artist.cover.uri, '600x600').toString()
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
