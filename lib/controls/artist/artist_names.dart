import 'package:flutter/material.dart';

import '/helpers/nav_keys.dart';
import '/pages/artist_page.dart';
import '/models/music_api/artist.dart';

class ArtistNames extends StatelessWidget {
  final Iterable<ArtistBase> artists;
  late final String _text = artists.map((artist) => artist.name).join(', ');

  ArtistNames({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    Widget artistNames = Text(
      _text,
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis
    );

    if(artists.length > 1) {
      return PopupMenuButton<ArtistBase>(
        padding: EdgeInsets.zero,
        menuPadding: EdgeInsets.zero,
        popUpAnimationStyle: AnimationStyle.noAnimation,
        offset: const Offset(20, -20),
        tooltip: '',
        itemBuilder: (_) => artists.map((artist) => _buildMenuItem(artist.name, artist)).toList(),
        onSelected: _goToArtistPage,
        child: artistNames
      );
    }

    return GestureDetector(
      onTap: () => _goToArtistPage(artists.first),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: artistNames,
      ),
    );
  }

  PopupMenuItem<ArtistBase> _buildMenuItem(String text, ArtistBase artist) {
    return PopupMenuItem(
      value: artist,
      height: 40,
      child: Text(text,),
    );
  }

  void _goToArtistPage(ArtistBase artist) {
    NavKeys.mainNav.currentState!.push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ArtistPage(artist),
        reverseTransitionDuration: Duration.zero,
      )
    );
  }
}
