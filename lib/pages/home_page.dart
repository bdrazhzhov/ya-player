import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/controls/album_card.dart';
import 'package:ya_player/controls/artist_card.dart';
import 'package:ya_player/models/music_api/album.dart';
import 'package:ya_player/models/music_api/artist.dart';
import 'package:ya_player/models/music_api/block.dart';
import 'package:ya_player/music_api.dart';
import 'package:ya_player/pages/playlist_page.dart';

import '../app_state.dart';
import '../models/music_api/playlist.dart';
import '../services/service_locator.dart';

class HomePage extends StatelessWidget {
  final _appState = getIt<AppState>();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _appState.landingNotifier,
      builder: (_, List<Block> blocks, __) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Home', style: theme.textTheme.displayMedium),
              ...blocks.map((block) => LandingBlock(block: block)).toList()
            ],
          ),
        );
      },
    );
  }
}

class LandingBlock extends StatelessWidget {
  final Block block;

  const LandingBlock({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(block.title ?? '', style: theme.textTheme.titleLarge,),
        if(block.entities.isNotEmpty)
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
        return _PlaylistCard(playlist: playlist);
      case Album:
        final album = entity as Album;
        return AlbumCard(album, 180);
      case LikedArtist:
        final artist = entity as LikedArtist;
        return ArtistCard(artist, 180);
      default:
        debugPrint('Unknown entity type: ${entity.runtimeType.toString()}');
        return null;
    }
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
  });

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: (){ Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => PlaylistPage(playlist),
              reverseTransitionDuration: Duration.zero,
            )
          );
        },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: (playlist.image != null) ?
                  CachedNetworkImage(
                  width: 180,
                  height: 180,
                  imageUrl: MusicApi.imageUrl(playlist.image!, '200x200').toString()
                ) : const SizedBox(
                  width: 180,
                  height: 180,
                  child: Center(child: Text('No Image'),),
                ),
              ),
              Text(playlist.title),
              if(playlist.description != null) Expanded(
                child: Text(
                  playlist.description!,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(color: theme.colorScheme.outline,)
                )
              ),
              Text(
                '${playlist.tracksCount} tracks',
                style: TextStyle(color: theme.colorScheme.outline,)
              )
            ],
          ),
        ),
      ),
    );
  }
}

