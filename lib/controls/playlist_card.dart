import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'yandex_image.dart';
import '/pages/playlist_page.dart';
import '/models/music_api/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final double width;

  const PlaylistCard(this.playlist, {super.key, required this.width});

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
              (playlist.image != null) ?
                YandexImage(uriTemplate: playlist.image!, size: 200, borderRadius: 8) :
                SizedBox(
                  width: width,
                  height: width,
                  child: const Center(child: Text('No Image')),
                ),
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
}
