import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/controls/like_button.dart';
import '/app_state.dart';
import '/models/music_api/track.dart';
import '/services/service_locator.dart';
import 'track_cover.dart';

class TrackListItem extends StatefulWidget {
  final Track track;
  final bool isPlaying;
  final bool isCurrent;
  final bool showAlbum;
  final bool showArtistName;
  final int trackIndex;
  final bool showTrackNumber;
  final void Function()? onTap;

  const TrackListItem({
    super.key,
    required this.track,
    this.isPlaying = false,
    this.isCurrent = false,
    this.showAlbum = true,
    this.showArtistName = true,
    this.trackIndex = 0,
    this.showTrackNumber = false,
    this.onTap,
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
        cursor: track.isAvailable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (event){ if(!track.isAvailable) return; isHovered = true; setState(() {}); },
        onExit: (event){ if(!track.isAvailable) return; isHovered = false; setState(() {}); },
        child: Container(
          decoration: BoxDecoration(color: isHovered || widget.isCurrent ? theme.colorScheme.inversePrimary : Colors.transparent),
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            children: [
              trackCover(track),
              Expanded(
                flex: 2,
                child: trackTitle(track, theme),
              ),
              if(widget. showArtistName) Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 2),
                  child: buildArtistName(track),
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
              if(isHovered || appState.isLikedTrack(widget.track))
                SizedBox(
                  width: 50,
                  child: LikeButton(
                    likeCondition: () => appState.isLikedTrack(track),
                    onLikeClicked: () => appState.likeTrack(track)
                  )
                )
              else
                const SizedBox(width: 50),
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

  SizedBox trackCover(Track track) {
    return SizedBox(
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
            trackNumber: widget.showTrackNumber ? widget.trackIndex + 1 : null,
          );
        }
      ),
    );
  }

  Padding trackTitle(Track track, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.showTrackNumber ? 6 : 24,
        right: 2
      ),
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
    );
  }

  Text buildArtistName(Track track) {
    return Text(
      track.artist,
      softWrap: false,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
