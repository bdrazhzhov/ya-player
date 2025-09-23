import 'package:flutter/material.dart';

import '/controls/horizontal_list_with_title.dart';
import '/controls/page_loading_indicator.dart';
import '/controls/playlist_card.dart';
import '/controls/playlist_flexible_space.dart';
import '/controls/sliver_track_list.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api_types.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class ChartPage extends StatelessWidget {
  late final Future<Playlist> _playlistData = _musicApi.chart();
  final _musicApi = getIt<MusicApi>();

  ChartPage({super.key});

  static const double _playlistsWidth = 165;
  static const double _playlistsSpacing = 20;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Playlist>(
        future: _playlistData,
        builder: (_, AsyncSnapshot<Playlist> snapshot) {
          if (snapshot.hasData) {
            final Playlist playlist = snapshot.data!;
            final l10n = AppLocalizations.of(context)!;
            final theme = Theme.of(context);

            return PageBase(
              flexibleSpace: PlaylistFlexibleSpace(playlist: playlist),
              slivers: [
                SliverTrackList(
                  playContext: playlist,
                  tracks: snapshot.data!.tracks,
                ),
                if (playlist.similarPlaylists.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.only(top: 36),
                    sliver: SliverToBoxAdapter(
                      child: HorizontalListWithTitle(
                        title: Text(
                          l10n.chart_similarPlaylists,
                          style: theme.textTheme.titleLarge,
                        ),
                        itemWidth: _playlistsWidth + _playlistsSpacing,
                        spacing: _playlistsSpacing,
                        children: playlist.similarPlaylists
                            .map((p) => PlaylistCard(p, width: _playlistsWidth))
                            .toList(),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return PageLoadingIndicator();
          }
        });
  }
}
