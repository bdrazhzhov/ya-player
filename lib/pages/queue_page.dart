import 'package:flutter/material.dart';
import '../app_state.dart';
import '../controls/track_list.dart';
import '../models/music_api/track.dart';
import '../services/service_locator.dart';

class QueuePage extends StatelessWidget {
  final String queueName;
  final _appState = getIt<AppState>();

  QueuePage({super.key, required this.queueName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Playback queue', style: theme.textTheme.displayMedium)),
              IconButton(onPressed: (){}, icon: const Icon(Icons.repeat)),
              IconButton(onPressed: (){}, icon: const Icon(Icons.shuffle)),
              const SizedBox(width: 32)
            ],
          ),
          const SizedBox(height: 50),
          ValueListenableBuilder(
            valueListenable: _appState.queueTracks,
            builder: (_, List<Track> tracks, __) {
              return TrackList(tracks, showAlbum: true, showHeader: true, queueName: queueName);
            },
          ),
        ],
      ),
    );
  }
}
