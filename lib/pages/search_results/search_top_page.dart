import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '/controls/album_card.dart';
import '/controls/artist_card.dart';
import '/controls/playlist_card.dart';
import '/controls/podcast_card.dart';
import '/controls/search/best_result_artist_card.dart';
import '/controls/search/best_result_wave_card.dart';
import '/controls/track_card.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/album.dart';
import '/models/music_api/artist.dart';
import '/models/music_api/playlist.dart';
import '/models/music_api/podcast.dart';
import '/models/music_api/search.dart';
import '/models/music_api/track.dart';
import '../../controls/search/best_result_recent_release_card.dart';

class SearchTopPage extends StatelessWidget {
  final Iterable<Object> items;
  final Iterable<Object> bestResults;
  final double _itemWidth = 200;

  const SearchTopPage({super.key, required this.items, required this.bestResults});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        if (bestResults.isNotEmpty) ...[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 12,
              crossAxisCount: 2,
              mainAxisExtent: 96,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                final result = bestResults.elementAt(index);

                if (result is BestResultArtist) {
                  return BestResultArtistCard(result);
                } else if (result is BestResultWave) {
                  return BestResultWaveCard(result);
                } else if (result is BestResultRecentRelease) {
                  return BestResultRecentReleaseCard(bestResult: result);
                } else {
                  return Text('Unknown best result type: ${result.runtimeType.toString()}');
                }
              },
              childCount: bestResults.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16))
        ],
        SliverGrid(
          gridDelegate: CustomSliverGridDelegateExtent(
            crossAxisSpacing: 12,
            maxCrossAxisExtent: _itemWidth,
            height: _itemWidth + 60,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, index) => _buildItemWidget(items.elementAt(index)),
            childCount: items.length,
          ),
        ),
      ],
    );
  }

  Widget _buildItemWidget(Object item) {
    Widget widget = Text('Unknown: ${item.runtimeType.toString()}');

    switch (item) {
      case Artist():
        widget = ArtistCard(item, _itemWidth);
      case Track():
        widget = TrackCard(track: item, width: _itemWidth);
      case Podcast():
        widget = PodcastCard(item, _itemWidth);
      case Album():
        widget = AlbumCard(item, _itemWidth);
      case Playlist():
        widget = PlaylistCard(item, width: _itemWidth);
    }

    return widget;
  }
}
