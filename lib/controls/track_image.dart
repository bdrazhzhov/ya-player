import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../music_api.dart';

class TrackImage extends StatelessWidget {
  const TrackImage({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: appState.trackNotifier,
        builder: (_, value, __) {
          if(value != null) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: CachedNetworkImage(
                width: 75,
                height: 75,
                imageUrl: MusicApi.trackImageUrl(value, '75x75').toString(),
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            );
          }
          else {
            return const Text('No image');
          }
        }
    );
  }
}
