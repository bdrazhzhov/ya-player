import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/podcast.dart';
import 'package:ya_player/pages/podcast_page.dart';

import '../music_api.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final double width;

  const PodcastCard(this.podcast, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? podcastDescription;
    if(podcast.shortDescription != null) {
      podcastDescription = podcast.shortDescription!;
    }
    else if(podcast.description != null) {
      podcastDescription = podcast.description!;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => PodcastPage(podcast),
              reverseTransitionDuration: Duration.zero,
            )
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
                    imageUrl: MusicApi.imageUrl(podcast.image, '200x200')
                ),
              ),
              Text(
                  podcast.title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              if(podcast.type == PodcastType.podcast)
                ...[
                  if(podcastDescription!= null)
                    Text(
                      podcastDescription,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    '${podcast.tracksCount} episodes',
                    style: TextStyle(
                      color: theme.colorScheme.outline,
                      fontSize: theme.textTheme.labelMedium?.fontSize
                    ),
                  )
                ]
              else
                Text(
                  podcast.artist,
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                    fontSize: theme.textTheme.labelMedium?.fontSize
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                )
            ],
          ),
        ),
      ),
    );
  }
}
