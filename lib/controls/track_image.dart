import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../music_api.dart';
import '../pages/current_track_page.dart';
import '../services/service_locator.dart';

class TrackImage extends StatelessWidget {
  final bool isExpandable;
  TrackImage({super.key, required this.isExpandable,});

  final AppState _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
        valueListenable: _appState.trackNotifier,
        builder: (_, track, __) {
          if(track != null) {
            Widget image = const Text('No image');

            if(track.coverUri != null) {
              image = Padding(
                padding: const EdgeInsets.all(2.0),
                child: CachedNetworkImage(
                  width: 50,
                  height: 50,
                  imageUrl: MusicApi.imageUrl(track.coverUri!, '50x50').toString(),
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              );
            }
            if(isExpandable) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: OpenContainer(
                  closedColor: Colors.transparent,
                  closedBuilder: (BuildContext context, void Function() action) {
                    return image;
                  },
                  openBuilder: (BuildContext context, void Function({Object? returnValue}) action) {
                    return CurrentTrackPage();
                  },
                ),
              );
            }
            else {
              return image;
            }
          }
          else {
            return const Text('No image');
          }
        }
    );
  }
}
