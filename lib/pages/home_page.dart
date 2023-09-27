import 'package:flutter/material.dart';
import 'package:ya_player/pages/page_base.dart';

import '../models/music_api/block.dart';
import '../app_state.dart';
import '../controls/page_block.dart';
import '../services/service_locator.dart';

class HomePage extends StatelessWidget {
  final _appState = getIt<AppState>();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return PageBase(
      title: 'Home',
      slivers: [
        ValueListenableBuilder(
          valueListenable: _appState.landingNotifier,
          builder: (_, List<Block> blocks, __) {
            return SliverList.builder(
              itemCount: blocks.length,
              itemBuilder: (BuildContext context, int index) {
                return PageBlock(block: blocks[index]);
              }
            );
          },
        )
      ]
    );
  }
}
