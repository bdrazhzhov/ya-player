import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

import '/helpers/nav_keys.dart';
import '/pages/artist_page.dart';
import '/models/music_api/artist.dart';

class ArtistNames extends StatelessWidget {
  final Iterable<ArtistBase> artists;
  late final String _text = artists.map((artist) => artist.name).join(', ');

  late final _entries = artists
      .map((artist) => MenuItem(
            label: artist.name,
            icon: Icons.person,
            onSelected: () => _goToArtistPage(artist),
          ))
      .toList();

  ArtistNames({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    Widget artistNames = Text(_text, softWrap: false, maxLines: 1, overflow: TextOverflow.ellipsis,);

    return GestureDetector(
      onTap: () {
        if(artists.length > 1) {
          showContextMenu(context, contextMenu: _buildMenu(context));
        }
        else {
          _goToArtistPage(artists.first);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: artistNames,
      ),
    );
  }

  ContextMenu _buildMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;

    return ContextMenu(
      entries: _entries,
      position: renderBox.localToGlobal(Offset.zero),
      padding: const EdgeInsets.all(8.0),
    );
  }

  void _goToArtistPage(ArtistBase artist) {
    NavKeys.mainNav.currentState!.push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => ArtistPage(artist),
      reverseTransitionDuration: Duration.zero,
    ));
  }
}
