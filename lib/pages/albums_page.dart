import 'package:flutter/material.dart';

import '../app_state.dart';
import '../controls/album_card.dart';
import '../models/music_api/album.dart';
import '../services/service_locator.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();
    final size = MediaQuery.of(context).size;
    double width = size.width / 3;
    if(width < 130) {
      width = 130;
    } else if(width > 200) {
      width = 200;
    }

    return SingleChildScrollView(
      child: ValueListenableBuilder<List<Album>>(
        valueListenable: appState.albumsNotifier,
        builder: (_, albums, __) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: albums.map((album) => AlbumCard(album, width)).toList(),
          );
        }
      ),
    );
  }
}
