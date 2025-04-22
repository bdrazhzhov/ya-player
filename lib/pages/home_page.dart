import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/pages/page_base.dart';
import '/models/music_api/block.dart';
import '/services/app_state.dart';
import '/controls/page_block.dart';
import '/services/service_locator.dart';

class HomePage extends StatelessWidget {
  final _appState = getIt<AppState>();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBase(
      title: AppLocalizations.of(context)!.page_main,
      slivers: [
        ValueListenableBuilder(
          valueListenable: _appState.landingNotifier,
          builder: (_, List<Block> blocks, __) {
            return SliverList.builder(
              itemCount: blocks.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    PageBlock(block: blocks[index]),
                    const SizedBox(height: 50)
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
