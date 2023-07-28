import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/playlist.dart';

import '../app_state.dart';
import '../controls/playlist_card.dart';
import '../services/service_locator.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final appState = getIt<AppState>();
  static const double _minWidth = 162;
  static const double _maxWidth = 208;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ValueListenableBuilder<List<Playlist>>(
        valueListenable: appState.playlistsNotifier,
        builder: (_, playlists, __) {
          return LayoutBuilder(
            builder: (_, BoxConstraints constraints) {
              int columnsNumber = 3;
              double width = constraints.maxWidth / columnsNumber;

              //TODO: rework for case with width and spacing
              while(true) {
                if(width < _minWidth) columnsNumber -= 1;
                if(columnsNumber == 0) {
                  columnsNumber = 1;
                  width = constraints.maxWidth;
                  break;
                }
                if(width > _maxWidth) columnsNumber += 1;

                width = constraints.maxWidth / columnsNumber;

                if(columnsNumber == 1 || width >= _minWidth && width <= _maxWidth) break;
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: playlists.map((playlist) => PlaylistCard(playlist, width: width)).toList(),
              );
            },
          );
        }
      ),
    );
  }
}

