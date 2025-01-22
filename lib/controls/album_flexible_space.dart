import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/music_api/album.dart';
import 'flexible_space.dart';

class AlbumFlexibleSpace extends StatelessWidget {
  final Album album;

  const AlbumFlexibleSpace({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FlexibleSpace(
      imageUrl: album.ogImage,
      type: FlexibleSpaceType.album,
      title: album.title,
      actions: Row(
        children: [
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
      )
    );
  }
}
