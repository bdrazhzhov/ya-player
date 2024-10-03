import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';

import 'yandex_image.dart';
import '../pages/playlist_page.dart';
import '../models/music_api/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final double width;
  static const _descriptionHeight = 60;
  static const _countsHeight = 50;

  const PlaylistCard(this.playlist, {super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double height = (
        playlist.description != null
            ? _descriptionHeight + _countsHeight
            : _countsHeight
    ) + width;

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
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              (playlist.image != null) ?
                YandexImage(uriPlaceholder: playlist.image!, size: 200, borderRadius: 8) :
                SizedBox(
                  width: width,
                  height: width,
                  child: const Center(child: Text('No Image')),
                ),
              Text(HtmlCharacterEntities.decode(playlist.title)),
              if(playlist.description != null) Expanded(
                child: Text(
                  HtmlCharacterEntities.decode(playlist.description!),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(color: theme.colorScheme.outline)
                )
              ),
              Text(
                '${playlist.tracksCount} tracks',
                style: TextStyle(color: theme.colorScheme.outline)
              )
            ],
          ),
        ),
      ),
    );
  }
}
