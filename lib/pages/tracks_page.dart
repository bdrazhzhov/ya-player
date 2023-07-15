import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ya_player/app_state.dart';
import 'package:ya_player/models/music_api/track.dart';
import 'package:ya_player/services/service_locator.dart';

import '../music_api.dart';
import 'page_base_layout.dart';

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
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 650;

    final columnWidths = isWide ? const <int, TableColumnWidth>{
      0: FixedColumnWidth(60),
      1: FlexColumnWidth(1.5),
      2: FlexColumnWidth(1),
      3: FlexColumnWidth(1),
      4: FixedColumnWidth(50),
    } : const <int, TableColumnWidth>{
      0: FixedColumnWidth(60),
      1: FlexColumnWidth(),
      2: FixedColumnWidth(50),
    };

    return PageBaseLayout(
      title: 'Tracks',
      body: SingleChildScrollView(
        child: ValueListenableBuilder<List<Track>>(
          valueListenable: appState.likedTracksNotifier,
          builder: (_, tracks, __) {
            final df = DateFormat('mm:ss');

            return Table(
              columnWidths: columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: tracks.map((track) {
                return TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: track.coverUri == null ?
                    const Text('No image') :
                    CachedNetworkImage(
                      width: 60,
                      height: 60,
                      fit: BoxFit.fitWidth,
                      imageUrl: MusicApi.imageUrl(track.coverUri!, '120x120').toString(),
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(track.title),
                          if(track.version != null) Expanded(
                            child: Text(
                              ' (${track.version!})',
                              style: TextStyle(color: theme.colorScheme.outline),
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                      if(!isWide) _buildArtistName(track),
                    ],
                  ),
                ),
                if(isWide) ...[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: _buildArtistName(track),
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
                  ],
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(df.format(DateTime.fromMillisecondsSinceEpoch(track.duration!.inMilliseconds, isUtc: true))),
                )
              ]);
              }).toList()
            );
          }
        ),
      ),
    );
  }

  Text _buildArtistName(Track track) {
    return Text(
      track.artists.map((e) => e.name).join(', '),
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
