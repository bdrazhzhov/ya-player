import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../notifiers/play_button_notifier.dart';
import '../app_state.dart';
import '../models/music_api/track.dart';
import '../services/service_locator.dart';
import 'track_list/track_cover.dart';


class TrackList extends StatefulWidget {
  final List<Track> tracks;
  final String queueName;
  final bool showAlbum;
  final bool showHeader;

  const TrackList(
      this.tracks, {
      super.key,
      this.showAlbum = false,
      this.showHeader = false,
      required this.queueName
  });

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  final appState = getIt<AppState>();
  Track? hoveredTrack;
  late bool isPlaying;

  @override
  void initState() {
    super.initState();

    appState.playButtonNotifier.addListener(playingStateListener);
    isPlaying = appState.playButtonNotifier.value == ButtonState.playing;
  }

  @override
  void dispose() {
    super.dispose();

    appState.playButtonNotifier.removeListener(playingStateListener);
  }

  void playingStateListener() {
    isPlaying = appState.playButtonNotifier.value == ButtonState.playing;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('mm:ss');

    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth > 650;

        final columnWidths = isWide ? [
          const FlexColumnWidth(1.5),
          const FlexColumnWidth(1),
          if(widget.showAlbum) const FlexColumnWidth(1),
          const FixedColumnWidth(50),
        ] : [
          const FlexColumnWidth(),
          const FixedColumnWidth(50),
        ];

        return Table(
            columnWidths: columnWidths.asMap(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              if(widget.showHeader && isWide) TableRow(
                  children: [
                    const Text('TRACK'),
                    const Text('ARTIST'),
                    if(widget.showAlbum) const Text('ALBUM'),
                    const Center(child: Icon(Icons.schedule))
                  ]
              ),
              ...widget.tracks.mapIndexed((index, track) {
                String trackDuration = '';
                if(track.duration != null) {
                  trackDuration = df.format(DateTime.fromMillisecondsSinceEpoch(track.duration!.inMilliseconds, isUtc: true));
                }

                return TableRow(
                    decoration: BoxDecoration(
                        color: theme.colorScheme.onInverseSurface,
                        border: Border.all(width: 1, color: theme.colorScheme.surface)
                    ),
                    children: [
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: [
                          const FixedColumnWidth(52),
                          const FlexColumnWidth(),
                        ].asMap(),
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: MouseRegion(
                                  onEnter: (event){ hoveredTrack = track; setState(() {}); },
                                  onExit: (event){ hoveredTrack = null; setState(() {}); },
                                  child: ValueListenableBuilder(
                                      valueListenable: appState.trackNotifier,
                                      builder: (_, Track? currentTrack, __) {
                                        return TrackCover(
                                          track,
                                          isCurrent: currentTrack != null && currentTrack == track,
                                          isHovered: track == hoveredTrack,
                                          isPlaying: isPlaying,
                                          onPressed: (bool isPlaying) {
                                            if(isPlaying) {
                                              appState.pause();
                                            } else {
                                              appState.playTracks(widget.tracks, index, widget.queueName);
                                            }
                                          },
                                        );
                                      }
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                            text: track.title,
                                            children: [
                                              if(track.version != null)
                                                TextSpan(
                                                  text: ' (${track.version!})',
                                                  style: TextStyle(color: theme.colorScheme.outline),
                                                )
                                            ]
                                        )
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
                        if(widget.showAlbum) Padding(
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
            )
          ]
        );
      },
    );
  }

  Text _buildArtistName(Track track) {
    return Text(
      track.artist,
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
