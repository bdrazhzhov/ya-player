import 'package:flutter/material.dart';
import 'package:ya_player/controls/podcast_card.dart';
import 'package:ya_player/models/music_api/non_music_catalog.dart';

import '../app_state.dart';
import '../services/service_locator.dart';

class PodcastsBooksPage extends StatelessWidget {
  final _appState = getIt<AppState>();

  PodcastsBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<NonMusicCatalog?>(
      valueListenable: _appState.nonMusicNotifier,
      builder: (_, catalog, __) {
        if(catalog == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                catalog.title,
                style: theme.textTheme.displayLarge,
              ),
              ...catalog.blocks.map((block) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      block.title ?? 'No title: ${block.id}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      block.description ?? '',
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(
                      height: 250,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: block.entities.map((e) {
                          return PodcastCard(e, 160);
                        }).toList(),
                      ),
                    )
                  ],
                );
              }),
            ],
          ),
        );
      }
    );
  }
}
