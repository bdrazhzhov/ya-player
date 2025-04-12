import 'package:flutter/material.dart';

import '/controls/album_card.dart';
import '/controls/artist_card.dart';
import '/controls/playlist_card.dart';
import '/controls/sliver_track_list.dart';
import '/models/music_api/album.dart';
import '/pages/search_results/podcasts_page.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/playlist.dart';
import '/models/music_api/track.dart';
import 'search_results/top_page.dart';
import '/models/music_api/artist.dart';
import '/models/music_api/search.dart';
import '/music_api.dart';
import '/services/service_locator.dart';

class SearchResultMixedPage extends StatelessWidget {
  final String text;
  final SearchFilter? filter;

  SearchResultMixedPage({super.key, required this.text, this.filter});

  final _musicApi = getIt<MusicApi>();

  @override
  Widget build(BuildContext context) {
    // debugPrint('buildSearchResults');

    return FutureBuilder(
      future: _musicApi.searchMixed(text: text, filter: filter),
      builder: (BuildContext context, AsyncSnapshot<SearchResultMixed> snapshot) {
        // debugPrint(snapshot.toString());
        // debugPrint(snapshot.hasData.toString());
        // debugPrint(snapshot.data.toString());

        if(!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: const Text('Searching...'));
        }

        final items = snapshot.data!.items;

        if(items.isEmpty) {
          return SliverToBoxAdapter(child: const Text('Nothing found'));
        }

        switch(snapshot.data!.filter) {
          case null:
            return SearchTopPage(items: items);
          case SearchFilter.artist:
            return buildResultsWidget(items);
          case SearchFilter.track:
            return SliverTrackList(
              tracks: items.map((i) => i as Track).toList(),
            );
          case SearchFilter.album:
            return buildResultsWidget(items);
          case SearchFilter.playlist:
            return buildResultsWidget(items);
          case SearchFilter.podcast:
            return PodcastsPage(items: items);
          case SearchFilter.book:
            return PodcastsPage(items: items);
        }
      },
    );
  }

  Widget buildResultsWidget(Iterable<Object> items) {
    const double itemWidth = 200;
    List<Object> data = items.toList();

    return SliverGrid(
      gridDelegate: CustomSliverGridDelegateExtent(
        crossAxisSpacing: 12,
        maxCrossAxisExtent: itemWidth,
        height: itemWidth + 60
      ),
      delegate: SliverChildBuilderDelegate(
        (_, index) => buildResultItem(data[index], itemWidth),
        childCount: data.length
      )
    );
  }

  Widget buildResultItem(Object item, double itemWidth) {
    Widget widget = const Text('Unknown');

    switch(item) {
      case Artist():
        return ArtistCard(item, itemWidth);
      case Album():
        return AlbumCard(item, itemWidth);
      case Playlist():
        return PlaylistCard(item, width: itemWidth);
      // case Podcast():
      //   return PodcastCard(item, itemWidth);
    }

    return widget;
  }
}
