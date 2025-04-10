import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';

import '/l10n/app_localizations.dart';
import 'yandex_image.dart';
import '/pages/playlist_page.dart';
import '/models/music_api/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final double width;

  const PlaylistCard(this.playlist, {super.key, required this.width});

  static const _borderRadius = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => PlaylistPage(playlist),
            reverseTransitionDuration: Duration.zero,
          )
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              (playlist.image != null && playlist.image!.isNotEmpty) ?
                YandexImage(
                  uriTemplate: playlist.image,
                  size: width,
                  borderRadius: _borderRadius
                ) :
                _buildNoImage(theme),
              Text(HtmlCharacterEntities.decode(playlist.title)),
              if(playlist.description != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 40
                  ),
                  child: Text(
                    HtmlCharacterEntities.decode(playlist.description!),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(color: theme.colorScheme.outline)
                  ),
                ),
              Text(
                AppLocalizations.of(context)!.tracks_count(playlist.tracksCount),
                style: TextStyle(color: theme.colorScheme.outline)
              )
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect _buildNoImage(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: SizedBox(
            width: width,
            child: const Center(child: Icon(Icons.queue_music, size: 72)),
          ),
        ),
      ),
    );
  }
}
