import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/music_api/album.dart';
import 'yandex_image.dart';

class AlbumFlexibleSpace extends StatelessWidget {
  final Album album;

  const AlbumFlexibleSpace({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (settings!.currentExtent == settings.minExtent) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: YandexImage(
              uriTemplate: album.ogImage,
              size: 300,
              borderRadius: 8
            ),
          ),
          Expanded(child: Text(album.title)),
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
          YandexImage(
            uriTemplate: album.ogImage,
            size: 300,
            borderRadius: 8
          ),
          const SizedBox(width: 20),
          Flexible(
            child: SizedBox(
              height: infoBlockHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.album_album),
                  Text(
                    album.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.headlineLarge,
                  ),
                  Row(
                    children: [
                      Text('${l10n.album_artist}:'),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('${album.artists.first.name} · ${album
                            .year}'),
                      ),
                    ],
                  ),
                  if(album.description != null)
                    ...[
                      SizedBox(height: 8),
                      Flexible(
                      child: Tooltip(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          border: Border.all(color: theme.focusColor),
                          borderRadius: BorderRadius.all(Radius.circular(6))
                        ),
                        richMessage: WidgetSpan(
                          child: SizedBox(
                            width: 400,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(album.description!),
                            ),
                          ),
                        ),
                        child: Text(album.description!,
                          maxLines: 3,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                    )],
                  SizedBox(height: 8),
                  Row(children: [
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
                  ])
                ],
              ),
            ),
          )
        ],
      );
    }
  }
}
