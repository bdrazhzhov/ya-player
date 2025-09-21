import 'package:flutter/material.dart';

import '/models/music_api/track.dart';
import 'track_list/track_list_item.dart';

class TrackList extends StatelessWidget {
  final List<Track> tracks;
  final bool showAlbum;
  final int startIndex;

  const TrackList(
    this.tracks, {
    super.key,
    this.showAlbum = false,
    required this.startIndex,
  });

  // final _playerState = getIt<PlayerState>();
  // final _appState = getIt<AppState>();
  // bool isQueueLoaded = false;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    tracks.skip(startIndex).take(5).toList().asMap().forEach((index, track) {
      index += startIndex;

      children.add(
        TrackListItem(
          track: track,
          trackIndex: index,
          showTrackNumber: false,
          showAlbum: showAlbum,
          showArtistName: false,
          tracks: tracks,
          playContext: tracks,
          // onTap: () async {
          //   if (!track.isAvailable) return;
          //
          //   final queue = getIt<PlaybackQueue>();
          //   if (!isQueueLoaded) {
          //     queue.replaceTracks(tracks);
          //     queue.moveTo(index);
          //     isQueueLoaded = true;
          //   }
          //
          //   getIt<Player>().playPause();
          // },
        ),
      );
    });

    return Column(children: children);
  }
}
