import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/controls/like_button.dart';
import '/controls/track_actions.dart';
import '/models/music_api/track.dart';
import '/player/player.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import 'chart_position.dart';
import 'track_cover.dart';

class TrackListItem extends StatefulWidget {
  final Track track;
  final bool showAlbum;
  final bool showArtistName;
  final int trackIndex;
  final bool showTrackNumber;
  final Object playContext;
  final Iterable<Track> tracks;

  const TrackListItem({
    super.key,
    required this.track,
    this.showAlbum = true,
    this.showArtistName = true,
    this.trackIndex = 0,
    this.showTrackNumber = false,
    required this.playContext,
    required this.tracks,
  });

  @override
  State<TrackListItem> createState() => _TrackListItemState();
}

class _TrackListItemState extends State<TrackListItem> {
  bool isHovered = false;
  final appState = getIt<AppState>();
  final df = DateFormat('mm:ss');
  bool isCurrent = false;

  @override
  void initState() {
    super.initState();

    appState.trackNotifier.addListener(onTrackChange);
    onTrackChange();
  }

  @override
  void dispose() {
    appState.trackNotifier.removeListener(onTrackChange);

    super.dispose();
  }

  void onTrackChange() {
    isCurrent = appState.trackNotifier.value == widget.track;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Track track = widget.track;

    String trackDuration = '';
    if (track.duration != null) {
      trackDuration = df
          .format(DateTime.fromMillisecondsSinceEpoch(track.duration!.inMilliseconds, isUtc: true));
    }

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: track.isAvailable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (event) {
          if (!track.isAvailable) return;
          isHovered = true;
          setState(() {});
        },
        onExit: (event) {
          if (!track.isAvailable) return;
          isHovered = false;
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
              color:
                  isHovered || isCurrent ? theme.colorScheme.inversePrimary : Colors.transparent),
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            children: [
              if (track.chart != null)
                SizedBox(width: 30, child: ChartPosition(chartItem: track.chart!)),
              trackCover(track),
              Expanded(
                flex: 2,
                child: trackTitle(track, theme),
              ),
              if (widget.showArtistName)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 2),
                    child: buildArtistName(track),
                  ),
                ),
              if (widget.showAlbum)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 2),
                    child: Text(
                      track.albumName,
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              if (isHovered || appState.isLikedTrack(widget.track))
                SizedBox(
                  width: 50,
                  child: LikeButton(
                    likeCondition: () => appState.isLikedTrack(track),
                    onLikeClicked: () => appState.likeTrack(track),
                  ),
                )
              else
                const SizedBox(width: 50),
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: isHovered
                      ? TrackActions(
                          track: track,
                          playContext: widget.playContext,
                          trackIndex: widget.trackIndex,
                        )
                      : Text(trackDuration),
                ),
              ),
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
      child: TrackCover(
        widget.track,
        isCurrent: isCurrent,
        isHovered: isHovered,
        trackNumber: widget.showTrackNumber ? widget.trackIndex + 1 : null,
      ),
    );
  }

  Padding trackTitle(Track track, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(left: widget.showTrackNumber ? 6 : 24, right: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: track.title,
              children: [
                if (track.version != null)
                  TextSpan(
                    text: ' (${track.version!})',
                    style: TextStyle(color: theme.colorScheme.outline),
                  )
              ],
            ),
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

  void onTap() {
    if (appState.playContext != widget.playContext) {
      appState.playContent(widget.playContext, widget.tracks, widget.trackIndex);
      return;
    }

    getIt<Player>().playPauseByIndex(widget.trackIndex);
  }
}
