import 'dart:async';

import 'package:flutter/material.dart';

import '/controls/album_flexible_space.dart';
import '/controls/tracks_header.dart';
import '/app_state.dart';
import '/controls/sliver_track_list.dart';
import '/music_api.dart';
import '/controls/page_loading_indicator.dart';
import '/models/music_api/album.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class AlbumPage extends StatelessWidget {
  final _appState = getIt<AppState>();
  final _musicApi = getIt<MusicApi>();
  late final Future<AlbumWithTracks> _albumInfo;

  AlbumPage(albumId, {super.key}) {
    _albumInfo = _musicApi.albumWithTracks(albumId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AlbumWithTracks>(
        future: _albumInfo,
        builder: (BuildContext context, AsyncSnapshot<AlbumWithTracks> snapshot){
          if(snapshot.hasData)
          {
            final albumWithTracks = snapshot.data!;
            return PageBase(
              slivers: [
                SliverAppBar(
                  leading: const SizedBox.shrink(),
                  pinned: true,
                  collapsedHeight: 60,
                  expandedHeight: 200,
                  // flexibleSpace: buildFlexibleSpaceBar(),
                  flexibleSpace: AlbumFlexibleSpace(album: albumWithTracks.album),
                ),
                SliverPersistentHeader(
                  delegate: TracksHeader(),
                  pinned: true,
                ),

                SliverTrackList(
                  tracks: albumWithTracks.tracks,
                  albumMode: true,
                  onBeforeStartPlaying: (int? index) =>
                      _appState.playContent(albumWithTracks,
                          albumWithTracks.tracks, index),
                ),
              ],
            );
          }
          else
          {
            return const PageLoadingIndicator();
          }
        }
    );
  }
}

