import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '../audio_player.dart';
import '/app_state.dart';
import '/helpers/nav_keys.dart';
import '/models/music_api/track.dart';
import '/notifiers/progress_notifier.dart';
import '/services/service_locator.dart';
import 'like_button.dart';
import 'play_controls.dart';
import 'playing_speed_button.dart';
import 'track_image.dart';
import 'track_name.dart';

class ControlsBar extends StatefulWidget {
  final bool isExpandable;

  const ControlsBar({super.key, required this.isExpandable});

  @override
  State<StatefulWidget> createState() => _ControlsBar();
}

class _ControlsBar extends State<ControlsBar> {
  final AppState appState = getIt<AppState>();
  final audioPlayer = getIt<AudioPlayer>();
  bool isVolumeChangedInternally = false;

  _ControlsBar();

  @override
  void initState() {
    super.initState();

    audioPlayer.playbackEventMessageStream.listen((PlaybackEventMessage msg){
      if(isVolumeChangedInternally) return;

      isVolumeChangedInternally = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<ProgressBarState>(
          valueListenable: appState.progressNotifier,
          builder: (_, value, __) {
            return ProgressBar(
              progress: value.current,
              buffered: value.buffered,
              total: value.total,
              onSeek: audioPlayer.seek,
            );
          },
        ),
        Row(
            children: [
              PlayControls(),
              TrackImage(isExpandable: widget.isExpandable),
              TrackName(),
              ValueListenableBuilder<Track?>(
                valueListenable: appState.trackNotifier,
                builder: (_, track, __) {
                  if(track == null) return const SizedBox.shrink();

                  return LikeButton(track: track);
                }
              ),
              const Expanded(child: SizedBox(),),
              ValueListenableBuilder(
                valueListenable: appState.queueTracks,
                builder: (_, List<Track> tracks, Widget? child) {
                  if(tracks.isNotEmpty && child != null) {
                    // queue page is broken; removed till fix
                    return const SizedBox.shrink();
                    // return child;
                  }
                  else {
                    return const SizedBox.shrink();
                  }
                },
                child: IconButton(
                  icon: const Icon(Icons.queue_music),
                  onPressed: () {
                    NavKeys.mainNav.currentState!.pushReplacementNamed('/queue');
                  }
                ),
              ),
              ValueListenableBuilder(
                valueListenable: appState.trackNotifier,
                builder: (_, Track? track, __) {
                  if(track?.type == TrackType.podcast
                      || track?.type == TrackType.audiobook) {
                    return PlayingSpeedButton();
                  }
                  else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Slider(
                value: audioPlayer.volume,
                onChanged: (double value) async {
                  isVolumeChangedInternally = true;
                  await audioPlayer.setVolume(value);
                  setState((){});
                },
              )
            ]
        )
      ],
    );
  }
}
