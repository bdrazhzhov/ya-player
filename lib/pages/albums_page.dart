import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/music_api.dart';

import '../app_state.dart';
import '../models/music_api/album.dart';
import '../services/service_locator.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Albums'),
          ValueListenableBuilder<List<Album>>(
            valueListenable: appState.albumsNotifier,
            builder: (_, albums, __) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: albums.map((album) => _AlbumCard(album)).toList(),
              );
            }
          ),
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final Album album;

  const _AlbumCard(this.album);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            width: 200,
            height: 200,
            imageUrl: MusicApi.imageUrl(album.ogImage, '600x600').toString()
          ),
        ),
        Text(album.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          album.artists.first.name,
          style: TextStyle(color: theme.colorScheme.outline, fontSize: theme.textTheme.labelMedium?.fontSize),
        ),
        Text(
          album.year.toString(),
          style: TextStyle(color: theme.colorScheme.outline, fontSize: theme.textTheme.labelMedium?.fontSize),
        )
      ],
    );
  }
}
