import 'package:flutter/material.dart';
import 'package:ya_player/controls/album_card.dart';
import 'package:ya_player/pages/page_base.dart';

import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/album.dart';
import '/music_api.dart';
import '/services/service_locator.dart';

class NewReleasesPage extends StatelessWidget {
  final _musicApi = getIt<MusicApi>();
  late final future = _musicApi.newReleases();

  NewReleasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<List<Album>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No new releases available.'));
        }

        final albums = snapshot.data!;

        return PageBase(
          title: l10n.new_releases_title,
          slivers: [
            SliverPadding(
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.new_releases_subtitle,
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
                height: 254,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, index) => _buildItem(albums[index]),
                childCount: albums.length,
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildItem(Album album) {
    return AlbumCard(album, 200);
  }
}
