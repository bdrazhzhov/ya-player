import 'package:flutter/material.dart';

import '/models/music_api/track.dart';
import 'yandex_image.dart';

class TrackCard extends StatelessWidget {
  final Track track;
  final double width;

  const TrackCard({super.key, required this.track, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkResponse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(track.ogImage != null)
            YandexImage(
              uriTemplate: track.ogImage,
              size: width,
              borderRadius: 8
            ),
          Text(
            track.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            track.artist,
            style: TextStyle(fontSize: theme.textTheme.labelMedium?.fontSize),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
        ],
      )
    );
  }
}
