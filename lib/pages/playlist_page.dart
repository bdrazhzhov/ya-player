import 'package:flutter/material.dart';

import '/controls/sliver_track_list.dart';
import '/controls/yandex_image.dart';
import '/music_api.dart';
import '/controls/page_loading_indicator.dart';
import '/models/music_api/playlist.dart';
import '/player/players_manager.dart';
import '/player/tracks_source.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PlaylistPage extends StatelessWidget {
  final Playlist playlist;
  late final Future<Playlist> _playlistData;
  final _musicApi = getIt<MusicApi>();
  final _player = getIt<PlayersManager>();
  late final String _duration;

  PlaylistPage(this.playlist, {super.key}) {
    _playlistData = _musicApi.playlist(playlist.uid, playlist.kind);
    _duration = _calculateDuration();
    _playlistData.then((Playlist playlist){
      _player.currentPageTracksSourceData = TracksSource(
          sourceType: TracksSourceType.playlist,
          source: playlist,
          id: playlist.kind
      );
    });
  }

  String _calculateDuration() {
    String duration = '';
    if(playlist.duration.inHours > 0) duration += '${playlist.duration.inHours} hrs';
    if(playlist.duration.inMinutes > 0) {
      final remainingMinutes = playlist.duration.inMinutes - playlist.duration.inHours * 60;
      duration += ' $remainingMinutes min';
    }
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageBase(
      title: playlist.title,
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              if(playlist.image != null)
                YandexImage(uriPlaceholder: playlist.image!, size: 200)
              else
                const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: Text('No Image'),),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Playlist'),
                  Text(playlist.title),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(color: theme.colorScheme.outline),
                      text: 'Compiled by ',
                      children: [
                        TextSpan(
                          style: theme.textTheme.bodyMedium,
                          text: '${playlist.ownerName} · ${playlist.tracksCount} tracks · $_duration'
                        )
                      ]
                    )
                  ),
                  if(playlist.description != null) Text(playlist.description!),
                  Row(
                    children: [
                      TextButton(onPressed: (){}, child: const Text('Play')),
                      TextButton(onPressed: (){}, child: const Text('Like')),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        FutureBuilder<Playlist>(
          future: _playlistData,
          builder: (_, AsyncSnapshot<Playlist> snapshot){
            if(snapshot.hasData) {
              return SliverTrackList(tracks: snapshot.data!.tracks);
            }
            else {
              return const SliverToBoxAdapter(child: PageLoadingIndicator());
            }
          }
        )
      ],
    );
  }
}
