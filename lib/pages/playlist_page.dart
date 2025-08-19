import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '/controls/playlist_flexible_space.dart';
import '/controls/sliver_track_list.dart';
import '/services/music_api.dart';
import '/controls/page_loading_indicator.dart';
import '/models/music_api/playlist.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PlaylistPage extends StatefulWidget {
  final int uid;
  final int kind;

  const PlaylistPage({super.key, required this.uid, required this.kind});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late Future<Playlist> playlistData;
  late final StreamSubscription<(int,int)> playlistUpdatesSubscription;
  final musicApi = getIt<MusicApi>();
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Playlist>(
      future: playlistData,
      builder: (_, AsyncSnapshot<Playlist> snapshot){
        if(snapshot.hasData) {
          final Playlist playlist = snapshot.data!;

          return PageBase(
            flexibleSpace: PlaylistFlexibleSpace(playlist: playlist),
            slivers: [
              SliverTrackList(
                playContext: playlist,
                tracks: playlist.tracks,
              ),
            ],
          );
        }
        else {
          return const PageLoadingIndicator();
        }
      }
    );
  }

  @override
  void initState() {
    super.initState();

    loadData();
    playlistUpdatesSubscription = appState.playlistUpdatesStream.listen((data) {
      final (int uid, int kind) = data;

      if(uid == widget.uid && kind == widget.kind) {
        loadData();
        setState(() {});
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    playlistUpdatesSubscription.cancel();
  }

  void loadData() {
    playlistData = musicApi.playlist(widget.uid, widget.kind);
  }
}
