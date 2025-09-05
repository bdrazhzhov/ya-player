import 'package:flutter/material.dart';

import '/helpers/nav_keys.dart';
import '/models/music_api/artist.dart';
import '/pages/artist_page.dart';
import '../context_menu/context_menu.dart';
import '../context_menu/context_menu_item.dart';

class ArtistNames extends StatelessWidget {
  final Iterable<ArtistBase> artists;
  late final String _text = artists.map((artist) => artist.name).join(', ');

  late final _entries = artists
      .map((artist) => MenuItem(
            label: artist.name,
            icon: Icons.person,
            onTap: () => _goToArtistPage(artist),
          ))
      .toList();

  ArtistNames({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final artistNames = Text(
      _text,
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: theme.colorScheme.outline),
    );

    if (artists.length == 1) {
      return GestureDetector(
        onTap: () => _goToArtistPage(artists.first),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: artistNames,
        ),
      );
    }

    return ContextMenu(
      items: _entries,
      child: artistNames,
    );
  }

  void _goToArtistPage(ArtistBase artist) {
    NavKeys.mainNav.currentState!.push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => ArtistPage(artistId: artist.id),
      reverseTransitionDuration: Duration.zero,
    ));
  }
}
