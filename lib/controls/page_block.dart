import 'package:flutter/material.dart';
import 'package:ya_player/controls/mix_link_card.dart';
import 'package:ya_player/controls/podcast_card.dart';
import 'package:ya_player/controls/track_list.dart';

import '../models/music_api_types.dart';
import 'album_card.dart';
import 'artist_card.dart';
import 'playlist_card.dart';
import 'promotion_card.dart';

class PageBlock extends StatelessWidget {
  final Block block;

  const PageBlock({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(block.title ?? '', style: theme.textTheme.titleLarge,),
        if(block.description != null) Text(block.description!),
        if(block.entities.isNotEmpty)
          if(block.type == 'chart')
            _createChartBlock()
          else
            SizedBox(
              height: 300,
              child: ListView(
                // shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: _createEntityCards(context),
              ),
            )
      ],
    );
  }

  Widget _createChartBlock() {
    final tracks = block.entities.map((e) => e as Track);

    List<Track> leftTracks = tracks.take(5).toList();
    List<Track> rightTracks = tracks.skip(5).take(5).toList();

    return Row(
      children: [
        Flexible(child: TrackList(leftTracks, showAlbum: true)),
        Flexible(child: TrackList(rightTracks, showAlbum: true)),
      ],
    );
  }

  List<Widget> _createEntityCards(BuildContext context) {
    List<Widget> cards = [];

    for(Object entity in block.entities) {
      Widget? card = _createBlockEntityCard(context, entity);
      if(card == null) continue;
      cards.addAll([card, const SizedBox(width: 20)]);
    }

    if(cards.isNotEmpty) cards.removeLast();

    return cards;
  }

  Widget? _createBlockEntityCard(BuildContext context, entity) {
    switch(entity.runtimeType) {
      case Playlist:
        final playlist = entity as Playlist;
        return PlaylistCard(playlist, width: 180);
      case Album:
        final album = entity as Album;
        return AlbumCard(album, 180);
      case LikedArtist:
        final artist = entity as LikedArtist;
        return ArtistCard(artist, 180);
      case Promotion:
        final promotion = entity as Promotion;
        return PromotionCard(promotion, width: 300);
      case Podcast:
        final podcast = entity as Podcast;
        return PodcastCard(podcast, 180);
      case MixLink:
        final mixLink = entity as MixLink;
        return MixLinkCard(mixLink, width: 180);
      default:
        debugPrint('Unknown entity type: ${entity.runtimeType.toString()}');
        return null;
    }
  }
}
