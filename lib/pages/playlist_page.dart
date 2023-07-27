import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/controls/track_list.dart';
import 'package:ya_player/music_api.dart';

import '../models/music_api/playlist.dart';
import '../services/service_locator.dart';

class PlaylistPage extends StatelessWidget {
  final Playlist playlist;
  late final Future<Playlist> _playlistData;
  final _musicApi = getIt<MusicApi>();
  late final String _duration;

  PlaylistPage(this.playlist, {super.key}) {
    _playlistData = _musicApi.playlist(playlist.uid, playlist.kind);
    _duration = _calculateDuration();
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if(playlist.image != null)
                CachedNetworkImage(
                  width: 200,
                  height: 200,
                  imageUrl: MusicApi.imageUrl(playlist.image!, '200x200').toString()
                )
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
          FutureBuilder<Playlist>(
            future: _playlistData,
            builder: (_, AsyncSnapshot<Playlist> snapshot){
              if(snapshot.hasData) {
                return TrackList(snapshot.data!.tracks, showAlbum: true, showHeader: true);
              }
              else {
                return const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator()
                );
              }
            }
          ),
        ],
      ),
    );
  }
}
