import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ya_player/controls/playlist_card.dart';

import '../models/music_api_types.dart';
import 'custom_separated_hlist.dart';

class SimilarPlaylists extends StatelessWidget {
  final List<Playlist> playlists;

  const SimilarPlaylists({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Text(
          l10n.chart_similarPlaylists,
          style: theme.textTheme.titleLarge,
        ),
        CustomSeparatedHList(
          children: playlists.map((p) => PlaylistCard(p, width: 165)),
          separatorWidget: const SizedBox(width: 20),
        )
      ]
    );
  }
}
