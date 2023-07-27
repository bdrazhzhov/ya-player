import 'package:flutter/material.dart';

import '../models/music_api/block.dart';
import '../app_state.dart';
import '../controls/page_block.dart';
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
              ...blocks.map((block) => PageBlock(block: block)).toList()
            ],
          ),
        );
      },
    );
  }
}
