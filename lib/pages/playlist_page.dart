import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/app_state.dart';
import '/controls/sliver_track_list.dart';
import '/controls/yandex_image.dart';
import '/music_api.dart';
import '/controls/page_loading_indicator.dart';
import '/models/music_api/playlist.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PlaylistPage extends StatelessWidget {
  final Playlist playlist;
  late final Future<Playlist> _playlistData = _musicApi.playlist(playlist.uid, playlist.kind);
  final _appState = getIt<AppState>();
  final _musicApi = getIt<MusicApi>();

  PlaylistPage(this.playlist, {super.key});

  String _calculateDuration(AppLocalizations l10n) {
    String duration = '';
    if(playlist.duration.inHours > 0) duration += '${playlist.duration.inHours} ${l10n.date_hoursShort}';
    if(playlist.duration.inMinutes > 0) {
      final remainingMinutes = playlist.duration.inMinutes - playlist.duration.inHours * 60;
      duration += ' $remainingMinutes ${l10n.date_minutesShort}';
    }
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final duration = _calculateDuration(l10n);

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
                  Text(l10n.playlist),
                  Text(playlist.title),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(color: theme.colorScheme.outline),
                      text: l10n.playlist_compiledBy,
                      children: [
                        TextSpan(
                          style: theme.textTheme.bodyMedium,
                          text: ' ${playlist.ownerName} · ${l10n.tracks_count(playlist.tracksCount)} · $duration'
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
              return SliverTrackList(
                tracks: snapshot.data!.tracks,
                onBeforeStartPlaying: (int? index) =>
                    _appState.playContent(snapshot.data!, snapshot.data!.tracks, index)
              );
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
