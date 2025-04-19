import 'package:flutter/material.dart';

import '/controls/playlist_card.dart';
import 'page_base.dart';
import '/models/music_api/playlist.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/l10n/app_localizations.dart';
import '/music_api.dart';
import '/services/service_locator.dart';

class PopularPlaylistsPage extends StatelessWidget {
  final _musicApi = getIt<MusicApi>();
  late final future = _musicApi.newPlaylists();

  PopularPlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<List<Playlist>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No new playlists available.'));
        }

        final albums = snapshot.data!;

        return PageBase(
          title: l10n.popular_playlists_title,
          slivers: [
            SliverPadding(
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.popular_playlists_subtitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              padding: EdgeInsets.only(bottom: 16),
            ),
            SliverGrid(
              gridDelegate: CustomSliverGridDelegateExtent(
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                maxCrossAxisExtent: 200,
                height: 260,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, index) => PlaylistCard(albums[index], width: 200),
                childCount: albums.length,
              ),
            )
          ],
        );
      },
    );
  }
}
