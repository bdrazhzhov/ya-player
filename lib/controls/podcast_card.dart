import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';

import '../l10n/app_localizations.dart';
import '/models/music_api/podcast.dart';
import '/pages/podcast_page.dart';
import 'yandex_image.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final double width;

  const PodcastCard(this.podcast, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? podcastDescription;
    if (podcast.shortDescription != null) {
      podcastDescription = podcast.shortDescription!;
    } else if (podcast.description != null) {
      podcastDescription = podcast.description!;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => PodcastPage(podcast),
          reverseTransitionDuration: Duration.zero,
        ));
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          constraints: BoxConstraints(maxWidth: width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              YandexImage(uriTemplate: podcast.image, size: 200, borderRadius: 8),
              Text(
                HtmlCharacterEntities.decode(podcast.title),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (podcast.type == PodcastType.podcast) ...[
                if (podcastDescription != null)
                  Text(
                    HtmlCharacterEntities.decode(podcastDescription),
                    style: TextStyle(color: theme.colorScheme.outline),
                    maxLines: 2,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  "${podcast.tracksCount} ${AppLocalizations.of(context)!.episodes_count(podcast.tracksCount)}",
                  style: TextStyle(color: theme.colorScheme.outline),
                )
              ] else ...[
                Text(
                  HtmlCharacterEntities.decode(podcast.artist),
                  style: TextStyle(color: theme.colorScheme.outline),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                if (podcast.year != null)
                  Text(
                    podcast.year.toString(),
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
