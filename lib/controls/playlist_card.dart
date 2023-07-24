import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/music_api/playlist.dart';
import '../music_api.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final double width;

  const PlaylistCard(this.playlist, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
                width: width,
                height: width,
                imageUrl: MusicApi.imageUrl(playlist.ogImage, '600x600').toString()
            ),
          ),
          Text(
            playlist.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${playlist.tracksCount} tracks',
            style: TextStyle(
                color: theme.colorScheme.outline,
                fontSize: theme.textTheme.labelMedium?.fontSize
            ),
          ),
        ],
      ),
    );
  }
}
