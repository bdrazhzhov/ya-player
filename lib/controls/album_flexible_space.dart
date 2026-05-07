import 'package:flutter/material.dart';

import '/controls/play_context_button.dart';
import '/models/music_api/album.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import 'flexible_space.dart';
import 'like_button.dart';

class AlbumFlexibleSpace extends StatelessWidget {
  final AlbumWithTracks albumWithTracks;

  AlbumFlexibleSpace({super.key, required this.albumWithTracks});

  final _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return FlexibleSpace(
      imageUrl: albumWithTracks.album.ogImage,
      type: FlexibleSpaceType.album,
      title: albumWithTracks.album.title,
      actions: Row(
        children: [
          PlayContextButton(
              context: albumWithTracks.album, tracks: albumWithTracks.tracks),
          LikeButton(
            likeCondition: () => _appState.isLikedAlbum(albumWithTracks.album),
            onLikeClicked: () => _appState.likeAlbum(albumWithTracks.album),
          )
        ],
      ),
    );
  }
}
