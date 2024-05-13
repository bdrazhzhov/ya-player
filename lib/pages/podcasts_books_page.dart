import 'package:flutter/material.dart';

import '../controls/page_block.dart';
import '../models/music_api_types.dart';
import '../app_state.dart';
import '../services/service_locator.dart';

class PodcastsBooksPage extends StatelessWidget {
  final _appState = getIt<AppState>();

  PodcastsBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<List<Block>>(
      valueListenable: _appState.nonMusicNotifier,
      builder: (_, blocks, __) {

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Podcasts and books', style: theme.textTheme.displayMedium),
              ...blocks.map((block) => PageBlock(block: block))
            ],
          ),
        );
      }
    );
  }
}
