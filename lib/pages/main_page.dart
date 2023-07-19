import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../controls/play_controls.dart';
import '../controls/track_image.dart';
import '../controls/track_name.dart';
import '../notifiers/progress_notifier.dart';
import '../services/service_locator.dart';
import 'main_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _appState = getIt<AppState>();

  _MainPageState() {
    _appState.init();
  }

  @override
  void dispose() {
    _appState.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const Expanded(child: MainScreen()),
          ValueListenableBuilder<ProgressBarState>(
            valueListenable: _appState.progressNotifier,
            builder: (_, value, __) {
              return ProgressBar(
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: _appState.seek,
              );
            },
          ),
          Row(
              children: [
                PlayControls(),
                TrackImage(),
                TrackName(),
                ValueListenableBuilder<bool>(
                    valueListenable: _appState.trackLikeNotifier,
                    builder: (_, value, __) {
                      var iconData = value ? Icons.favorite : Icons.favorite_border;
                      return IconButton(
                          icon: Icon(iconData),
                          onPressed: _appState.likeCurrentTrack
                      );
                    }
                ),
                const Expanded(child: SizedBox(),),
                if(defaultTargetPlatform == TargetPlatform.windows ||
                    defaultTargetPlatform == TargetPlatform.linux ||
                    defaultTargetPlatform == TargetPlatform.macOS) Slider(
                  value: _appState.volume,
                  onChanged: (double value) {
                    setState((){
                      _appState.volume = value;
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
      ),
    );
  }
}
