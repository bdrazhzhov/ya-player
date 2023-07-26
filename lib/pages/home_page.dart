import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/models/music_api/block.dart';
import 'package:ya_player/music_api.dart';

import '../app_state.dart';
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
              scrollDirection: Axis.horizontal,
              children: block.entities
                  .map((e) => _createBlockEntityCard(context, e))
                  .whereNot((c) => c == null)
                  .map((e) => e!).expand((element) => [element, const SizedBox(width: 20)])
                  .toList()..removeLast(),
            ),
          )
      ],
    );
  }

  Widget? _createBlockEntityCard(BuildContext context, BlockEntity entity) {
    final theme = Theme.of(context);

    switch(entity.runtimeType) {
      case BlockPlaylist:
        final playlist = entity as BlockPlaylist;
        return SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  width: 180,
                  height: 180,
                  imageUrl: MusicApi.imageUrl(playlist.image, '200x200').toString()
                ),
              ),
              Text(playlist.title),
              Expanded(
                child: Text(
                  playlist.description,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(color: theme.colorScheme.outline,)
                )
              ),
              Text(
                '${playlist.trackCount} tracks',
                style: TextStyle(color: theme.colorScheme.outline,)
              )
            ],
          ),
        );
      default:
        debugPrint('Unknown entity type: ${entity.runtimeType.toString()}');
        return null;
    }
  }
}

