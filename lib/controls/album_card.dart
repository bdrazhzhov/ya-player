import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';

import '/models/music_api/album.dart';
import '/pages/album_page.dart';
import 'yandex_image.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final double width;

  const AlbumCard(this.album, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkResponse(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AlbumPage(album.id),
            reverseTransitionDuration: Duration.zero,
          )
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YandexImage(uriTemplate: album.ogImage, size: width, borderRadius: 8),
            Text(
              HtmlCharacterEntities.decode(album.title),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              album.artists.isNotEmpty ? HtmlCharacterEntities.decode(album.artists.first.name) : '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.outline),
            ),
            Text(
              [
                album.year.toString(),
                if(album.version != null )...[' · ', album.version!]
              ].join(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.outline),
            )
          ],
        ),
      ),
    );
  }
}
