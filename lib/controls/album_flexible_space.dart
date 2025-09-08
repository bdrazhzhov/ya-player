import 'package:flutter/material.dart';
import 'package:ya_player/services/app_state.dart';
import 'package:ya_player/services/service_locator.dart';

import '/l10n/app_localizations.dart';
import '/models/music_api/album.dart';
import '/player/player.dart';
import '/services/player_state.dart';
import 'flexible_space.dart';
import 'like_button.dart';

class AlbumFlexibleSpace extends StatelessWidget {
  final AlbumWithTracks albumWithTracks;

  AlbumFlexibleSpace({super.key, required this.albumWithTracks});

  final _appState = getIt<AppState>();
  final _playerState = getIt<PlayerState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FlexibleSpace(
      imageUrl: albumWithTracks.album.ogImage,
      type: FlexibleSpaceType.album,
      title: albumWithTracks.album.title,
      actions: Row(
        children: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _playerState.playBackStateNotifier,
              builder: (context, value, child) {
                if (value == PlayBackState.playing &&
                    _appState.playContext == albumWithTracks.album) {
                  return Icon(Icons.pause);
                }
                return Icon(Icons.play_arrow);
              },
            ),
            tooltip: l10n.artist_play,
            onPressed: () {
              if (_appState.playContext == albumWithTracks.album) {
                getIt<Player>().playPause();
                return;
              }
              _appState.playContent(albumWithTracks.album, albumWithTracks.tracks);
            },
          ),
          LikeButton(
            likeCondition: () => _appState.isLikedAlbum(albumWithTracks.album),
            onLikeClicked: () => _appState.likeAlbum(albumWithTracks.album),
          )
        ],
      ),
    );
  }
}
