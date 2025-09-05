import 'package:async/async.dart';
import 'package:flutter/material.dart';

import '/models/music_api_types.dart';
import '/player/player.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'best_result_cover.dart';

class BestResultAlbumCover extends StatefulWidget {
  const BestResultAlbumCover({
    super.key,
    required this.bestResult,
    this.isHovered = false,
  });

  final BestResultAlbum bestResult;
  final bool isHovered;

  @override
  State<BestResultAlbumCover> createState() => _BestResultAlbumCoverState();
}

class _BestResultAlbumCoverState extends State<BestResultAlbumCover> {
  AlbumWithTracks? albumWithTracks;
  CancelableOperation<AlbumWithTracks>? albumOperation;
  final musicApi = getIt<MusicApi>();
  final appState = getIt<AppState>();
  final playerState = getIt<PlayerState>();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    albumOperation = CancelableOperation.fromFuture(musicApi.albumWithTracks(widget.bestResult.id));
    albumOperation?.value.then((album) {
      albumWithTracks = album;
      updateState();
    });
    appState.trackNotifier.addListener(updateState);
    playerState.playBackStateNotifier.addListener(updateState);
  }

  @override
  void dispose() {
    appState.trackNotifier.removeListener(updateState);
    playerState.playBackStateNotifier.removeListener(updateState);
    albumOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: BestResultCover(
        uriTemplate: widget.bestResult.cover?.uri,
        borderRadius: 4,
        hasPlayAnimation: !widget.isHovered && isPlaying,
        hasPlayPause: widget.isHovered,
        isPlaying: isPlaying,
      ),
    );
  }

  bool _isPlaying() {
    if (albumWithTracks == null) return false;
    if (appState.playContext is! Album) return false;

    final album = appState.playContext as Album;
    if (album.id != widget.bestResult.id) return false;

    Track? track = appState.trackNotifier.value;
    if (track == null) return false;

    return playerState.playBackStateNotifier.value == PlayBackState.playing &&
        albumWithTracks!.tracks.contains(track);
  }

  void _onTap() async {
    final playContext = appState.playContext;
    if (playContext is Album && playContext.id == widget.bestResult.id) {
      getIt<Player>().playPause();
      return;
    }

    if (albumWithTracks != null) {
      appState.playContent(albumWithTracks!.album, albumWithTracks!.tracks);
    }
  }

  void updateState() {
    isPlaying = _isPlaying();
    setState(() {});
  }
}
