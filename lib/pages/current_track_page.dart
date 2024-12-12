import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../controls/controls_bar.dart';
import '../controls/page_base_layout.dart';
import '../music_api.dart';
import '../services/service_locator.dart';

class CurrentTrackPage extends StatelessWidget {
  final AppState _appState = getIt<AppState>();

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
              const Align(
                alignment: Alignment.topLeft,
                child: BackButton(),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: MusicApi.imageUrl(track.coverUri!, '460x460').toString(),
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
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