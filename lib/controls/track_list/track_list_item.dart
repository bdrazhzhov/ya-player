import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../models/music_api/track.dart';
import '../../services/service_locator.dart';
import 'track_cover.dart';

class TrackListItem extends StatefulWidget {
  final Track track;
  final bool isPlaying;
  final bool isCurrent;
  final bool showAlbum;
  final void Function()? onTap;

  const TrackListItem({
    super.key,
    required this.track,
    this.isPlaying = false,
    this.isCurrent = false,
    this.showAlbum = true,
    this.onTap
  });

  @override
  State<TrackListItem> createState() => _TrackListItemState();
}

class _TrackListItemState extends State<TrackListItem> {
  bool isHovered = false;
  final appState = getIt<AppState>();
  final df = DateFormat('mm:ss');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Track track = widget.track;

    String trackDuration = '';
    if(track.duration != null) {
      trackDuration = df.format(DateTime.fromMillisecondsSinceEpoch(track.duration!.inMilliseconds, isUtc: true));
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event){ isHovered = true; setState(() {}); },
        onExit: (event){ isHovered = false; setState(() {}); },
        child: Container(
          decoration: BoxDecoration(color: isHovered || widget.isCurrent ? theme.colorScheme.inversePrimary : Colors.transparent),
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: ValueListenableBuilder(
                  valueListenable: appState.trackNotifier,
                  builder: (_, Track? currentTrack, __) {
                    return TrackCover(
                      widget.track,
                      isCurrent: currentTrack != null && currentTrack == track,
                      isHovered: isHovered,
                      isPlaying: widget.isPlaying,
                    );
                  }
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 2),
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
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 2),
                  child: _buildArtistName(track),
                ),
              ),
              if(widget.showAlbum) Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 2),
                  child: Text(
                    track.albums.isNotEmpty ? track.albums.first.title : '',
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                width: 50,
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: Text(trackDuration),
              )
            ],
          ),
        ),
      ),
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
