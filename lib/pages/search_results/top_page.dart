import 'package:flutter/material.dart';
import 'package:ya_player/controls/album_card.dart';
import 'package:ya_player/controls/playlist_card.dart';
import 'package:ya_player/controls/podcast_card.dart';
import 'package:ya_player/models/music_api/podcast.dart';

import '../../models/music_api/album.dart';
import '../../models/music_api/playlist.dart';
import '/controls/artist_card.dart';
import '/models/music_api/artist.dart';
import '/models/music_api/track.dart';
import '/controls/track_card.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';

class SearchTopPage extends StatelessWidget {
  final Iterable<Object> items;
  final double _itemWidth = 200;

  const SearchTopPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final data = items.toList();

    return SliverGrid(
      gridDelegate: CustomSliverGridDelegateExtent(
          crossAxisSpacing: 12,
          maxCrossAxisExtent: _itemWidth,
          height: _itemWidth + 60
      ),
      delegate: SliverChildBuilderDelegate(
        (_, index) => _buildItemWidget(data[index]),
        childCount: data.length
      )
    );
  }

  Widget _buildItemWidget(Object item) {
    Widget widget = Text('Unknown: ${item.runtimeType.toString()}');

    switch (item) {
      case Artist():
        widget = ArtistCard(item, _itemWidth);
      case Track():
        widget = TrackCard(track: item, width: _itemWidth);
      case Album():
        widget = AlbumCard(item, _itemWidth);
      case Podcast():
        widget = PodcastCard(item, _itemWidth);
      case Playlist():
        widget = PlaylistCard(item, width: _itemWidth);
    }

    return widget;
  }
}
