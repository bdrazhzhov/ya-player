import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/playlist.dart';

import '../app_state.dart';
import '../music_api.dart';
import '../services/service_locator.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Playlists'),
          ValueListenableBuilder<List<Playlist>>(
              valueListenable: appState.playlistsNotifier,
              builder: (_, playlists, __) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: playlists.map((playlist) => _PlaylistCard(playlist)).toList(),
                );
              }
          ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const _PlaylistCard(this.playlist);

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
              imageUrl: MusicApi.imageUrl(playlist.ogImage, '600x600').toString()
          ),
        ),
        Text(playlist.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          '${playlist.tracksCount} tracks',
          style: TextStyle(color: theme.colorScheme.outline, fontSize: theme.textTheme.labelMedium?.fontSize),
        ),
      ],
    );
  }
}
