import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/pages/page_base.dart';
import '/app_state.dart';
import '/controls/album_card.dart';
import '/models/music_api/album.dart';
import '/services/service_locator.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return PageBase(
      title: AppLocalizations.of(context)!.page_albums,
      slivers: [
        SliverToBoxAdapter(
          child: ValueListenableBuilder<List<Album>>(
              valueListenable: appState.albumsNotifier,
              builder: (_, albums, __) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: albums.map((album) => AlbumCard(album, 200)).toList(),
                );
              }
          ),
        )
      ]
    );
  }
}
