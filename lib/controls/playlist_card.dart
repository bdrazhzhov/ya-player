import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/music_api/playlist.dart';
import '../music_api.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final double width;

  const PlaylistCard(this.playlist, {super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double height = playlist.description != null ? 300 : 240;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: (playlist.image != null) ?
            CachedNetworkImage(
                width: width,
                height: width,
                imageUrl: MusicApi.imageUrl(playlist.image!, '200x200').toString()
            ) :  SizedBox(
              width: width,
              height: width,
              child: const Center(child: Text('No Image'),),
            ),
          ),
          Text(playlist.title),
          if(playlist.description != null) Expanded(
              child: Text(
                  playlist.description!,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(color: theme.colorScheme.outline,)
              )
          ),
          Text(
              '${playlist.tracksCount} tracks',
              style: TextStyle(color: theme.colorScheme.outline,)
          )
        ],
      ),
    );
  }
}
