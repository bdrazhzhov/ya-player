import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/controls/sliver_track_list.dart';
import '/controls/page_loading_indicator.dart';
import '/models/music_api_types.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class ArtistTracksPage extends StatelessWidget {
  final Artist artist;
  final _musicApi = getIt<MusicApi>();
  late final Future<List<Track>> tracksFuture = _musicApi.artistPopularTracks(artist.id);

  ArtistTracksPage({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<Track>>(
        future: tracksFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Track>> snapshot){
          if(snapshot.hasData)
          {
            final tracks = snapshot.data!;
            return PageBase(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20, bottom: 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            artist.name,
                            style: theme.textTheme.displayLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 20),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      l10n.artist_allTracks,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ),
                SliverTrackList(
                  playContext: artist,
                  tracks: tracks,
                )
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
