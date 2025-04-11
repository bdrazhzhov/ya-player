import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:ya_player/controls/sliver_track_list.dart';

import '/l10n/app_localizations.dart';
import '/controls/podcast_card.dart';
import '/models/music_api_types.dart';

import '../../helpers/custom_sliver_grid_delegate_extent.dart';

class PodcastsPage extends StatelessWidget {
  final Iterable<Object> items;
  final List<Podcast> podcasts = [];
  final List<PodcastEpisode> podcastEpisodes = [];
  final double _itemWidth = 200;

  PodcastsPage({super.key, required this.items}) {
    for (Object item in items) {
      if(item is Podcast) {
        podcasts.add(item);
      }
      else if(item is PodcastEpisode) {
        podcastEpisodes.add(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return MultiSliver(
      children: [
        SliverGrid(
          gridDelegate: CustomSliverGridDelegateExtent(
            crossAxisSpacing: 12,
            maxCrossAxisExtent: _itemWidth,
            height: _itemWidth + 60
          ),
          delegate: SliverChildBuilderDelegate(
            (_, index) => PodcastCard(podcasts[index], _itemWidth),
            childCount: podcasts.length
          )
        ),
        if(podcastEpisodes.isNotEmpty) SliverToBoxAdapter(
          child: Text(
            l10n.podcast_episodes,
            style: theme.textTheme.titleLarge,
          )
        ),
        if(podcastEpisodes.isNotEmpty) SliverTrackList(tracks: podcastEpisodes),
      ]
    );
  }
}
