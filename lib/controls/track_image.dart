import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../music_api.dart';
import '../services/service_locator.dart';

class TrackImage extends StatelessWidget {
  TrackImage({super.key,});

  final AppState _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _appState.trackNotifier,
        builder: (_, track, __) {
          if(track != null) {
            if(track.coverUri != null) {
              return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CachedNetworkImage(
                    width: 75,
                    height: 75,
                    imageUrl: MusicApi.imageUrl(track.coverUri!, '75x75').toString(),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
              );
            }
            else {
              return const Text('No image');
            }
          }
          else {
            return const Text('No image');
          }
        }
    );
  }
}
