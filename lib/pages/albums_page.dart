import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/l10n/app_localizations.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/pages/page_base.dart';
import '/app_state.dart';
import '/controls/album_card.dart';
import '/models/music_api/album.dart';
import '/services/service_locator.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  static const _itemWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return PageBase(
      title: AppLocalizations.of(context)!.page_albums,
      slivers: [
        ValueListenableBuilder<List<Album>>(
          valueListenable: appState.albumsNotifier,
          builder: (_, albums, __) {
            return SliverLayoutBuilder(
              builder: (_, SliverConstraints sliverConstraints) {
                final constraints = sliverConstraints.asBoxConstraints();
                final spacing = 12.0;

                if(constraints.maxWidth < spacing * (albums.length - 1) + albums.length * _itemWidth)
                {
                  return SliverGrid.builder(
                    itemCount: albums.length,
                    gridDelegate: CustomSliverGridDelegateExtent(
                        crossAxisSpacing: spacing,
                        maxCrossAxisExtent: _itemWidth,
                        height: _itemWidth + 60
                    ),
                    itemBuilder: (_, index) => AlbumCard(albums[index], _itemWidth),
                  );
                }

                return SliverToBoxAdapter(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: albums.map((album) => AlbumCard(album, _itemWidth)).toList(),
                  ),
                );
              },
            );
          }
        )
      ]
    );
  }
}
