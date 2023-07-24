import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/playlist.dart';

import '../app_state.dart';
import '../controls/playlist_card.dart';
import '../services/service_locator.dart';
import '../controls/page_base_layout.dart';

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

    return PageBaseLayout(
      title: 'Playlists',
      body: SingleChildScrollView(
        child: ValueListenableBuilder<List<Playlist>>(
            valueListenable: appState.playlistsNotifier,
            builder: (_, playlists, __) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: playlists.map((playlist) => PlaylistCard(playlist, width)).toList(),
              );
            }
        ),
      ),
    );
  }
}

