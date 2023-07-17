import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/music_api.dart';

import '../app_state.dart';
import '../models/music_api/album.dart';
import '../services/service_locator.dart';
import 'album_page.dart';
import 'page_base_layout.dart';

class AlbumsPage extends StatelessWidget {
  final GlobalKey<NavigatorState> _navKey = GlobalKey();

  AlbumsPage({super.key});

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

    return
      Navigator(
        key: _navKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings){
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => PageBaseLayout(
              title: 'Albums',
              body: SingleChildScrollView(
                child: ValueListenableBuilder<List<Album>>(
                    valueListenable: appState.albumsNotifier,
                    builder: (_, albums, __) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: albums.map((album) => _AlbumCard(album, width)).toList(),
                      );
                    }
                ),
              ),
            )
          );
        },
      );
  }
}

class _AlbumCard extends StatelessWidget {
  final Album album;
  final double width;

  const _AlbumCard(this.album, this.width);

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
                imageUrl: MusicApi.imageUrl(album.ogImage, '600x600').toString()
              ),
            ),
            Text(
              album.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              album.artists.first.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontSize: theme.textTheme.labelMedium?.fontSize
              ),
            ),
            Text(
              album.year.toString(),
              style: TextStyle(color: theme.colorScheme.outline, fontSize: theme.textTheme.labelMedium?.fontSize),
            )
          ],
        ),
      ),
    );
  }
}
