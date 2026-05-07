import 'package:flutter/material.dart';

import '/controls/mix_link_card.dart';
import '/controls/podcast_card.dart';
import '/controls/track_list.dart';
import '/helpers/nav_keys.dart';
import '/models/music_api_types.dart';
import '/pages/chart_page.dart';
import '/pages/new_releases_page.dart';
import '/pages/popular_playlists_page.dart';
import 'album_card.dart';
import 'artist_card.dart';
import 'horizontal_list_with_title.dart';
import 'page_section_header.dart';
import 'playlist_card.dart';
import 'promotion_card.dart';

class PageBlock extends StatelessWidget {
  final Block block;

  const PageBlock({super.key, required this.block});

  static const ignoredTypes = [
    'personal-playlists',
    'play-contexts',
    'promotions',
    'editorial-playlists',
    'album-chart',
    'playlist-with-tracks',
    'recently-played'
  ];

  static const double _entityCardWidth = 180;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (block.type == 'chart') ...[
          _buildEntityTitle(context),
          _createChartBlock()
        ] else
          HorizontalListWithTitle(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (block.title != null)
                  PageSectionHeader(
                    title: block.title!,
                    onPressed: !ignoredTypes.contains(block.type)
                        ? () => _navigateToAll(block.type, context)
                        : null,
                  ),
                if (block.description != null) Text(block.description!),
              ],
            ),
            spacing: 20,
            itemWidth: _entityCardWidth,
            children: block.entities
                .map((e) => _createBlockEntityCard(context, e))
                .whereType<Widget>()
                .toList(),
          )
      ],
    );
  }

  Widget _buildEntityTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title != null)
          PageSectionHeader(
            title: block.title!,
            onPressed: !ignoredTypes.contains(block.type)
                ? () => _navigateToAll(block.type, context)
                : null,
          ),
        if (block.description != null) Text(block.description!),
      ],
    );
  }

  Widget _createChartBlock() {
    final tracks = block.entities.map((e) => e as Track).toList();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              TrackList(
                tracks,
                showAlbum: true,
                startIndex: 0,
              ),
              TrackList(
                tracks,
                showAlbum: true,
                startIndex: 5,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Flexible(
                child: TrackList(
                  tracks,
                  showAlbum: true,
                  startIndex: 0,
                ),
              ),
              Flexible(
                child: TrackList(
                  tracks,
                  showAlbum: true,
                  startIndex: 5,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget? _createBlockEntityCard(BuildContext context, entity) {
    switch (entity.runtimeType) {
      case const (Playlist):
        final playlist = entity as Playlist;
        return PlaylistCard(playlist, width: _entityCardWidth);
      case const (Album):
        final album = entity as Album;
        return AlbumCard(album, _entityCardWidth);
      case const (Artist):
        final artist = entity as Artist;
        return ArtistCard(artist, _entityCardWidth);
      case const (Promotion):
        final promotion = entity as Promotion;
        return PromotionCard(promotion, width: _entityCardWidth);
      case const (Podcast):
        final podcast = entity as Podcast;
        return PodcastCard(podcast, _entityCardWidth);
      case const (MixLink):
        final mixLink = entity as MixLink;
        return MixLinkCard(mixLink, width: _entityCardWidth);
      default:
        debugPrint('Unknown entity type: ${entity.runtimeType.toString()}');
        return null;
    }
  }

  void _navigateToAll(String type, BuildContext context) {
    Widget? page;

    switch (type) {
      case 'chart':
        page = ChartPage();
      case 'podcasts':
        NavKeys.mainNav.currentState!.pushNamed('/podcasts_books');
      case 'new-releases':
        page = NewReleasesPage();
      case 'new-playlists':
        page = PopularPlaylistsPage();
    }

    if (page == null) return;

    NavKeys.mainNav.currentState!.push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => page!,
      reverseTransitionDuration: Duration.zero,
    ));
  }
}
