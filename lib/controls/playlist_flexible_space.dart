import 'package:flutter/material.dart';
import 'package:ya_player/controls/flexible_space.dart';

import '/l10n/app_localizations.dart';
import '/models/music_api_types.dart';

class PlaylistFlexibleSpace extends StatelessWidget {
  final Playlist playlist;

  const PlaylistFlexibleSpace({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final duration = _calculateDuration(l10n);

    return FlexibleSpace(
      imageUrl: playlist.image,
      type: FlexibleSpaceType.playlist,
      title: playlist.title,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(color: theme.colorScheme.outline),
              text: l10n.playlist_compiledBy,
              children: [
                TextSpan(
                  style: theme.textTheme.bodyMedium,
                  text: ': ${playlist.ownerName} · ${l10n.tracks_count(playlist.tracksCount)} · $duration'
                )
              ]
            )
          ),
          if(playlist.description != null)
            Text(
              playlist.description!,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis
            ),
        ],
      ),
      actions: Row(
        children: [
          TextButton(onPressed: (){}, child: const Text('Play')),
          TextButton(onPressed: (){}, child: const Text('Like')),
        ],
      )
    );
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
