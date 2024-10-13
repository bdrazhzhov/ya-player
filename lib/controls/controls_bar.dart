import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../helpers/nav_keys.dart';
import '../models/music_api/track.dart';
import '../notifiers/progress_notifier.dart';
// import '../services/audio_handler.dart';
import '../services/service_locator.dart';
import 'play_controls.dart';
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

  _ControlsBar();

  @override
  void initState() {
    super.initState();

    // getIt<MyAudioHandler>().volumeStream.listen((value){
    //   debugPrint('setState() volume');
    //   appState.volume = value;
    //   setState(() {});
    // });
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
              onSeek: appState.seek,
            );
          },
        ),
        Row(
            children: [
              PlayControls(),
              TrackImage(isExpandable: widget.isExpandable),
              TrackName(),
              ValueListenableBuilder<bool>(
                  valueListenable: appState.trackLikeNotifier,
                  builder: (_, value, __) {
                    var iconData = value ? Icons.favorite : Icons.favorite_border;
                    return IconButton(
                      icon: Icon(iconData),
                      onPressed: appState.likeCurrentTrack
                    );
                  }
              ),
              const Expanded(child: SizedBox(),),
              ValueListenableBuilder(
                valueListenable: appState.queueTracks,
                builder: (_, List<Track> tracks, Widget? child) {
                  if(tracks.isNotEmpty && child != null) {
                    return child;
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
              if(defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.macOS) Slider(
                value: appState.volume,
                onChanged: (double value) {
                  setState((){
                    appState.volume = value;
                  });
                },
              )
              else
                IconButton(
                  onPressed: (){
                    // pageController.jumpToPage(5);
                  },
                  icon: const Icon(Icons.account_box)
                )
            ]
        )
      ],
    );
  }
}