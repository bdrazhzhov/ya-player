import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/pages/chart_page.dart';
import '/controls/mix_link_card.dart';
import '/controls/podcast_card.dart';
import '/controls/track_list.dart';
import '/helpers/playback_queue.dart';
import '/models/music_api_types.dart';
import 'album_card.dart';
import 'artist_card.dart';
import 'playlist_card.dart';
import 'promotion_card.dart';

class PageBlock extends StatelessWidget {
  final Block block;

  const PageBlock({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    block.title ?? '',
                    style: theme.textTheme.titleLarge,
                  ),
                  if (block.description != null) Text(block.description!),
                ],
              ),
            ),
            if (block.type != 'personal-playlists')
              TextButton(
                onPressed: () => _navigateToAll(block.type, context),
                child: Text(l10n.pageBlock_viewAll),
              ),
          ],
        ),
        if (block.type == 'chart')
          _createChartBlock()
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _createEntityCards(context),
            ),
          ),
      ],
    );
  }

  Widget _createChartBlock() {
    final tracks = block.entities.map((e) => e as Track);

    List<Track> leftTracks = tracks.take(5).toList();
    List<Track> rightTracks = tracks.skip(5).take(5).toList();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              TrackList(
                leftTracks,
                showAlbum: true,
                queueName: QueueNames.trackList,
              ),
              TrackList(
                rightTracks,
                showAlbum: true,
                queueName: QueueNames.trackList,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Flexible(
                child: TrackList(
                  leftTracks,
                  showAlbum: true,
                  queueName: QueueNames.trackList,
                ),
              ),
              Flexible(
                child: TrackList(
                  rightTracks,
                  showAlbum: true,
                  queueName: QueueNames.trackList,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  List<Widget> _createEntityCards(BuildContext context) {
    List<Widget> cards = [];

    for (Object entity in block.entities) {
      Widget? card = _createBlockEntityCard(context, entity);
      if (card == null) continue;
      cards.addAll([card, const SizedBox(width: 20)]);
    }

    if (cards.isNotEmpty) cards.removeLast();

    return cards;
  }

  Widget? _createBlockEntityCard(BuildContext context, entity) {
    switch (entity.runtimeType) {
      case const (Playlist):
        final playlist = entity as Playlist;
        return PlaylistCard(playlist, width: 180);
      case const (Album):
        final album = entity as Album;
        return AlbumCard(album, 180);
      case const (Artist):
        final artist = entity as Artist;
        return ArtistCard(artist, 180);
      case const (Promotion):
        final promotion = entity as Promotion;
        return PromotionCard(promotion, width: 300);
      case const (Podcast):
        final podcast = entity as Podcast;
        return PodcastCard(podcast, 180);
      case const (MixLink):
        final mixLink = entity as MixLink;
        return MixLinkCard(mixLink, width: 180);
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
    }

    if (page == null) return;

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => page!,
      reverseTransitionDuration: Duration.zero,
    ));
  }
}
