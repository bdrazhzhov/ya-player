import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/music_api_types.dart';
import 'yandex_image.dart';

class PlaylistFlexibleSpace extends StatelessWidget {
  final Playlist playlist;

  const PlaylistFlexibleSpace({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final duration = _calculateDuration(l10n);

    if (settings!.currentExtent == settings.minExtent) {
      return Row(
        children: [
          YandexImage(uriTemplate: playlist.image, size: 50),
          Expanded(child: Text(playlist.title)),
          ElevatedButton(
            onPressed: () {},
            child: Row(
              children: [
                Icon(Icons.play_arrow),
                Text(l10n.album_play)
              ]
            )
          ),
          ElevatedButton(
            onPressed: () {},
            child: Row(
              children: [
                Icon(Icons.favorite),
                Text(l10n.album_like)
              ]
            )
          )
        ],
      );
    }
    else {
      double infoBlockHeight = settings.currentExtent;
      if (infoBlockHeight < 100) infoBlockHeight = 100;

      return Row(
        children: [
          YandexImage(uriTemplate: playlist.image, size: 200),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.playlist),
              Text(playlist.title),
              Text.rich(
                  TextSpan(
                      style: TextStyle(color: theme.colorScheme.outline),
                      text: l10n.playlist_compiledBy,
                      children: [
                        TextSpan(
                            style: theme.textTheme.bodyMedium,
                            text: ' ${playlist.ownerName} · ${l10n.tracks_count(playlist.tracksCount)} · $duration'
                        )
                      ]
                  )
              ),
              if(playlist.description != null) Text(playlist.description!),
              Row(
                children: [
                  TextButton(onPressed: (){}, child: const Text('Play')),
                  TextButton(onPressed: (){}, child: const Text('Like')),
                ],
              )
            ],
          )
        ],
      );
    }
  }

  String _calculateDuration(AppLocalizations l10n) {
    String duration = '';
    if(playlist.duration.inHours > 0) duration += '${playlist.duration.inHours} ${l10n.date_hoursShort}';
    if(playlist.duration.inMinutes > 0) {
      final remainingMinutes = playlist.duration.inMinutes - playlist.duration.inHours * 60;
      duration += ' $remainingMinutes ${l10n.date_minutesShort}';
    }
    return duration;
  }
}
