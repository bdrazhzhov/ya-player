import 'package:flutter/material.dart';

import '/services/app_state.dart';
import '/controls/controls_bar.dart';
import '/controls/page_base_layout.dart';
import '/controls/yandex_image.dart';
import '/services/service_locator.dart';

class CurrentTrackPage extends StatelessWidget {
  final _appState = getIt<AppState>();

  CurrentTrackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageBaseLayout(
      body: Center(
        child: ValueListenableBuilder(
        valueListenable: _appState.trackNotifier,
        builder: (_, track, __) {
          if(track == null) return const Text('No track');

          return Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: (){
                      Navigator.maybePop(context);
                    }
                  ),
                )
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 460,
                          maxHeight: 460,
                        ),
                        child: YandexImage(
                          uriTemplate: track.coverUri,
                          size: 460,
                          borderRadius: 8,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 460,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.labelLarge?.copyWith(fontSize: theme.textTheme.titleLarge?.fontSize),
                          ),
                          Text(
                            '${track.artist} — ${track.albums.first.title}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
                child: ControlsBar(isExpandable: false),
              )
            ]
          );
        })
      )
    );
  }

}