import 'package:flutter/material.dart';

import '/controls/flexible_space.dart';
import '/controls/play_context_button.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api_types.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import 'delete_playlist_button.dart';

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
          Text.rich(TextSpan(
              style: TextStyle(color: theme.colorScheme.outline),
              text: l10n.playlist_compiledBy,
              children: [
                TextSpan(
                    style: theme.textTheme.bodyMedium,
                    text:
                        ': ${playlist.ownerName} · ${l10n.tracks_count(playlist.tracksCount)} · $duration')
              ])),
          if (playlist.description != null)
            Text(playlist.description!,
                softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
      actions: Row(
        children: [
          PlayContextButton(context: playlist, tracks: playlist.tracks),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite),
            tooltip: l10n.playlist_like,
          ),
          DeletePlaylistButton(
            playlist: playlist,
            onDeleted: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      onTitleChanged: _onTitleChanged,
    );
  }

  String _calculateDuration(AppLocalizations l10n) {
    String duration = '';
    if (playlist.duration.inHours > 0) {
      duration += '${playlist.duration.inHours} ${l10n.date_hoursShort}';
    }
    if (playlist.duration.inMinutes > 0) {
      final remainingMinutes =
          playlist.duration.inMinutes - playlist.duration.inHours * 60;
      duration += ' $remainingMinutes ${l10n.date_minutesShort}';
    }
    return duration;
  }

  void _onTitleChanged(String newTitle) {
    getIt<AppState>().changePlaylistTitle(playlist, newTitle);
  }
}
