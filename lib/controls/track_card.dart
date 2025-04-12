import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/models/music_api/track.dart';
import 'yandex_image.dart';

class TrackCard extends StatelessWidget {
  final Track track;
  final double width;

  const TrackCard({super.key, required this.track, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkResponse(
      onTap: (){},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              YandexImage(
                  uriTemplate: track.ogImage,
                  size: width,
                  borderRadius: 8
              ),
              Positioned(
                left: 8,
                top: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      l10n.track_card_track,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: theme.textTheme.labelMedium?.fontSize
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Text(
            track.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            track.artist,
            style: TextStyle(
              color: theme.colorScheme.outline,
              fontSize: theme.textTheme.labelMedium?.fontSize
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
        ],
      )
    );
  }
}
