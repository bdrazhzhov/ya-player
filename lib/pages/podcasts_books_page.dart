import 'package:flutter/material.dart';

import '/controls/page_block.dart';
import '/models/music_api_types.dart';
import '/app_state.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PodcastsBooksPage extends StatelessWidget {
  final _appState = getIt<AppState>();

  PodcastsBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBase(
      title: 'Podcasts and books',
      slivers: [
        ValueListenableBuilder(
          valueListenable: _appState.nonMusicNotifier,
          builder: (_, List<Block> blocks, __) {
            return SliverList.builder(
              itemCount: blocks.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    PageBlock(block: blocks[index]),
                    const SizedBox(height: 70,)
                  ],
                );
              }
            );
          },
        )
      ]
    );
  }
}
