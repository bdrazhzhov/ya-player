import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/models/music_api/podcast_episode.dart';
import 'yandex_image.dart';

class PodcastEpisodesList extends StatelessWidget {
  final List<PodcastEpisode> episodes;

  const PodcastEpisodesList(this.episodes, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnWidths = [
      const FixedColumnWidth(60),
      const FlexColumnWidth(2),
      const FlexColumnWidth(1),
      const FixedColumnWidth(50),
    ];
    final df = DateFormat('mm:ss');

    return Table(
      columnWidths: columnWidths.asMap(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        ...episodes.map((episode) {
          String trackDuration = '';
          if(episode.duration != null) {
            trackDuration = df.format(DateTime.fromMillisecondsSinceEpoch(episode.duration!.inMilliseconds, isUtc: true));
          }

          return TableRow(
            decoration: BoxDecoration(
                color: theme.colorScheme.onInverseSurface,
                border: Border.all(width: 1, color: theme.colorScheme.surface)
            ),
            children: [
              YandexImage(
                uriTemplate: episode.albums.first.ogImage,
                width: 60,
                borderRadius: 8
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  episode.title,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  episode.albums.first.title,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(trackDuration),
              )
            ]);
          }
        )
      ]
    );
  }

}