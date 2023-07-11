import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ya_player/app_state.dart';
import 'package:ya_player/models/music_api/track.dart';
import 'package:ya_player/services/service_locator.dart';

import '../music_api.dart';

class TracksPage extends StatefulWidget {
  const TracksPage({super.key});

  @override
  State<TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          const Text('Tracks'),
          Expanded(
            child: SingleChildScrollView(
              child: ValueListenableBuilder<List<Track>>(
                valueListenable: appState.likedTracksNotifier,
                builder: (_, tracks, __) {
                  final df = DateFormat('mm:ss');
                  return Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FixedColumnWidth(60),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FixedColumnWidth(50),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: tracks.map((track) => TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CachedNetworkImage(
                          width: 60,
                          height: 60,
                          fit: BoxFit.fitWidth,
                          imageUrl: MusicApi.trackImageUrl(track, '120x120').toString(),
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            Text(track.title),
                            if(track.version != null) Expanded(
                              child: Text(
                                ' ${track.version!}',
                                style: TextStyle(color: theme.colorScheme.outline),
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          track.artists.map((e) => e.name).join(', '),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          track.albums.first.title,
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(df.format(DateTime.fromMillisecondsSinceEpoch(track.duration.inMilliseconds, isUtc: true)))
                    ])).toList()
                  );
                }
              ),
            ),
          )
        ],
      ),
    );
  }
}
