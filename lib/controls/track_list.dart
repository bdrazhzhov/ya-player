import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/music_api/track.dart';
import '../music_api.dart';

class TrackList extends StatelessWidget {
  final List<Track> tracks;
  final bool showAlbum;

  const TrackList(this.tracks, {super.key, required this.showAlbum});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 650;
    // final columnWidths = isWide ? const <int, TableColumnWidth>{
    //   0: FixedColumnWidth(60),
    //   1: FlexColumnWidth(1.5),
    //   2: FlexColumnWidth(1),
    //   3: FlexColumnWidth(1),
    //   4: FixedColumnWidth(50),
    // } : const <int, TableColumnWidth>{
    //   0: FixedColumnWidth(60),
    //   1: FlexColumnWidth(),
    //   2: FixedColumnWidth(50),
    // };
    final columnWidths = isWide ? [
      const FlexColumnWidth(1.5),
      const FlexColumnWidth(1),
      if(showAlbum) const FlexColumnWidth(1),
      const FixedColumnWidth(50),
    ] : [
      const FlexColumnWidth(),
      const FixedColumnWidth(50),
    ];
    final df = DateFormat('mm:ss');

    return Table(
      columnWidths: columnWidths.asMap(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        if(isWide) TableRow(
          children: [
            const Text('TRACK'),
            const Text('ARTIST'),
            if(showAlbum) const Text('ALBUM'),
            const Center(child: Icon(Icons.schedule))
          ]
        ),
        ...tracks.map((track) {
          String trackDuration = '';
          if(track.duration != null) {
            trackDuration = df.format(DateTime.fromMillisecondsSinceEpoch(track.duration!.inMilliseconds, isUtc: true));
          }

          return TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.onInverseSurface,
              border: Border.all(width: 1, color: theme.colorScheme.background)
            ),
            children: [
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: [
                const FixedColumnWidth(50),
                const FlexColumnWidth(),
              ].asMap(),
              children: [
                TableRow(
                  children: [
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
                              Text(
                                track.title,
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
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
                  ]
                )
              ],
            ),

            if(isWide) ...[
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: _buildArtistName(track),
              ),
              if(showAlbum) Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  track.albums.isNotEmpty ? track.albums.first.title : '',
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(trackDuration),
            )
          ]);
        }
      ).toList()]
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
