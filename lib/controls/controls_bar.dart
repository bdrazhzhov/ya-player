
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '/notifiers/track_duration_notifier.dart';
import '/audio_player.dart';
import '/app_state.dart';
import '/helpers/nav_keys.dart';
import '/models/music_api/track.dart';
import '/services/service_locator.dart';
import 'like_button.dart';
import 'play_controls.dart';
import 'playing_speed_button.dart';
import 'track_image.dart';
import 'track_name.dart';
import 'volume_control.dart';

class ControlsBar extends StatelessWidget {
  final AppState _appState = getIt<AppState>();
  final _audioPlayer = getIt<AudioPlayer>();
  
  final bool isExpandable;

  ControlsBar({super.key, required this.isExpandable});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<TrackDurationState>(
          valueListenable: _appState.progressNotifier,
          builder: (_, value, __) {
            return ProgressBar(
              progress: value.position,
              buffered: value.buffered,
              total: value.duration,
              onSeek: _audioPlayer.seek,
            );
          },
        ),
        Row(
            children: [
              PlayControls(),
              TrackImage(isExpandable: isExpandable),
              TrackName(),
              ValueListenableBuilder<Track?>(
                valueListenable: _appState.trackNotifier,
                builder: (_, track, __) {
                  if(track == null) return const SizedBox.shrink();

                  return LikeButton(track: track);
                }
              ),
              const Expanded(child: SizedBox(),),
              ValueListenableBuilder(
                valueListenable: _appState.queueTracks,
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
                valueListenable: _appState.trackNotifier,
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
              VolumeControl()
            ]
        )
      ],
    );
  }
}
