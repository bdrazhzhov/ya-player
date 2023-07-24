import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/podcast.dart';

import '../music_api.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final double width;

  const PodcastCard(this.podcast, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkResponse(
      onTap: () {
        // Navigator.of(context).push(
        //     PageRouteBuilder(
        //       pageBuilder: (_, __, ___) => AlbumPage(podcast),
        //       reverseTransitionDuration: Duration.zero,
        //     )
        // );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                  width: width,
                  height: width,
                  imageUrl: MusicApi.imageUrl(podcast.ogImage, '460x460').toString()
              ),
            ),
            Text(
                podcast.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              '${podcast.trackCount} episodes',
              style: TextStyle(color: theme.colorScheme.outline, fontSize: theme.textTheme.labelMedium?.fontSize),
            )
          ],
        ),
      ),
    );
  }
}
