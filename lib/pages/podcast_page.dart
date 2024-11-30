import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/models/music_api_types.dart';
import '/music_api.dart';
import '/player/players_manager.dart';
import '/services/service_locator.dart';

class PodcastPage extends StatelessWidget {
  final Podcast podcast;
  late final Future<AlbumWithTracks> _albumWidthTracks;
  final _musicApi = getIt<MusicApi>();
  final _durationFormat = DateFormat('mm:ss');
  final _player = getIt<PlayersManager>();

  PodcastPage(this.podcast, {super.key}) {
    _albumWidthTracks = _musicApi.albumWithTracks(podcast.id);
    // _albumWidthTracks.then((AlbumWithTracks albumWithTracks){
    //   _player.currentPageTracksSourceData = TracksSource(
    //       sourceType: TracksSourceType.album,
    //       source: albumWithTracks,
    //       id: albumWithTracks.album.id
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(podcast.title, style: theme.textTheme.displayMedium,),
          FutureBuilder<AlbumWithTracks>(
            future: _albumWidthTracks,
            builder: (_, AsyncSnapshot<AlbumWithTracks> snapshot) {
              if(snapshot.hasData) {
                List<Track> tracks = snapshot.data!.tracks;

                final columnWidths = [
                  if(podcast.isAvailable) const FixedColumnWidth(50),
                  const FixedColumnWidth(40),
                  if(tracks.first.pubDate != null) const FlexColumnWidth(1),
                  const FlexColumnWidth(7),
                  const FixedColumnWidth(50),
                ];

                return Table(
                  columnWidths: columnWidths.asMap(),
                  children: tracks.mapIndexed((int index, Track track) {
                    return TableRow(
                      children: [
                        if(podcast.isAvailable)
                          IconButton(
                              onPressed: () => _player.play(index),
                              icon: const Icon(Icons.play_arrow)
                          ),
                        if(podcast.tracksCount == 0)
                          Text((index + 1).toString())
                        else
                          Text((podcast.tracksCount - index).toString()),
                        if(track.pubDate != null)
                          Text(DateFormat.yMMMMd().format(track.pubDate!)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(track.title),
                        ),
                        Text(
                          _durationFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(track.duration!.inMilliseconds, isUtc: true)
                          )
                        )
                      ]
                    );
                  }).toList(),
                );
              }
              else {
                return const CircularProgressIndicator();
              }
            }
          )
        ],
      ),
    );
  }
}
