import 'package:async/async.dart';
import 'package:flutter/material.dart';

import '/models/music_api_types.dart';
import '/player/player.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/player_state.dart';
import '/services/service_locator.dart';
import 'best_result_cover.dart';

class BestResultArtistCover extends StatefulWidget {
  const BestResultArtistCover({
    super.key,
    required this.bestResult,
    this.isHovered = false,
  });

  final BestResultArtist bestResult;
  final bool isHovered;

  @override
  State<BestResultArtistCover> createState() => _BestResultArtistCoverState();
}

class _BestResultArtistCoverState extends State<BestResultArtistCover> {
  ArtistInfo? artistInfo;
  CancelableOperation<ArtistInfo>? artistInfoOperation;
  final musicApi = getIt<MusicApi>();
  final appState = getIt<AppState>();
  final playerState = getIt<PlayerState>();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    artistInfoOperation = CancelableOperation.fromFuture(musicApi.artistInfo(widget.bestResult.id));
    artistInfoOperation?.value.then((info) {
      artistInfo = info;
      updateState();
    });
    appState.trackNotifier.addListener(updateState);
    playerState.playBackStateNotifier.addListener(updateState);
  }

  @override
  void dispose() {
    appState.trackNotifier.removeListener(updateState);
    playerState.playBackStateNotifier.removeListener(updateState);
    artistInfoOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: BestResultCover(
        uriTemplate: widget.bestResult.cover?.uri,
        hasPlayAnimation: !widget.isHovered && isPlaying,
        hasPlayPause: widget.isHovered && artistInfo != null,
        isPlaying: isPlaying,
      ),
    );
  }

  bool _isPlaying() {
    if (artistInfo == null) return false;
    if (appState.playContext is! Artist) return false;

    final artist = appState.playContext as Artist;
    if (artist.id != widget.bestResult.id) return false;

    Track? track = appState.trackNotifier.value;
    if (track == null) return false;

    return playerState.playBackStateNotifier.value == PlayBackState.playing &&
        artistInfo!.popularTracks.contains(track);
  }

  void _onTap() async {
    final playContext = appState.playContext;
    if (playContext is Artist && playContext.id == widget.bestResult.id) {
      getIt<Player>().playPause();
      return;
    }

    appState.playContent(artistInfo!.artist, artistInfo!.popularTracks);
  }

  void updateState() {
    isPlaying = _isPlaying();
    setState(() {});
  }
}
