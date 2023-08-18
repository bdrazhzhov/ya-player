import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';

import '../models/music_api/album.dart';
import '../music_api.dart';
import '../pages/album_page.dart';

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
              pageBuilder: (_, __, ___) => AlbumPage(album),
              reverseTransitionDuration: Duration.zero,
            )
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                  width: width,
                  height: width,
                  imageUrl: MusicApi.imageUrl(album.ogImage, '200x200')
              ),
            ),
            Text(
              HtmlCharacterEntities.decode(album.title),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              album.artists.isNotEmpty ? HtmlCharacterEntities.decode(album.artists.first.name) : '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: theme.colorScheme.outline,
                  fontSize: theme.textTheme.labelMedium?.fontSize
              ),
            ),
            Text(
              <String>[album.year.toString(), if(album.version != null )...[' · ', album.version!]].join(),
              style: TextStyle(color: theme.colorScheme.outline, fontSize: theme.textTheme.labelMedium?.fontSize),
            )
          ],
        ),
      ),
    );
  }
}
