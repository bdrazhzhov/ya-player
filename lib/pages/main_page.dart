import 'package:flutter/material.dart';

import '/services/state_enums.dart';
import '/services/app_state.dart';
import '/services/audio_player.dart';
import '/controls/controls_bar.dart';
import '/services/service_locator.dart';
import '/controls/main_menu.dart';
import 'login_page.dart';
import 'main_screen.dart';
import 'app_loading_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final appState = getIt<AppState>();
  final audioPlayer = getIt<AudioPlayer>();

  @override
  void dispose() {
    audioPlayer.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: appState.mainPageState,
            builder: (_, UiState value, __) {
              Widget page;

              if(value == UiState.loading) {
                page = const AppLoadingPage();
              }
              else if(value == UiState.auth) {
                page = LoginPage();
              }
              else {
                page = _buildAppUi();
              }

              return page;
            },
          ),
          // const TitleBar(),
        ],
      )
    );
  }

  Column _buildAppUi() {
    return Column(
      children: [
        const Expanded(
          child: Row(
            children: [
              MainMenu(),
              Expanded(child: MainScreen())
            ],
          )
        ),
        ControlsBar(isExpandable: true)
      ],
    );
  }
}


