import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../controls/controls_bar.dart';
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
    return const Material(
      child: Column(
        children: [
          Expanded(child: MainScreen()),
          ControlsBar(isExpandable: true)
        ],
      ),
    );
  }
}
