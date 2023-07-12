import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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
    final size = MediaQuery.of(context).size;
    double width = size.width / 3;
    if(width < 130) {
      width = 130;
    } else if(width > 200) {
      width = 200;
    }

    var crossAxisAlignment = CrossAxisAlignment.start;
    if(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      crossAxisAlignment = CrossAxisAlignment.center;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          const Text('Playlists'),
          ValueListenableBuilder<List<Playlist>>(
              valueListenable: appState.playlistsNotifier,
              builder: (_, playlists, __) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: playlists.map((playlist) => _PlaylistCard(playlist, width)).toList(),
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
  final double width;

  const _PlaylistCard(this.playlist, this.width);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
                width: width,
                height: width,
                imageUrl: MusicApi.imageUrl(playlist.ogImage, '600x600').toString()
            ),
          ),
          Text(
            playlist.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${playlist.tracksCount} tracks',
            style: TextStyle(
              color: theme.colorScheme.outline,
              fontSize: theme.textTheme.labelMedium?.fontSize
            ),
          ),
        ],
      ),
    );
  }
}
