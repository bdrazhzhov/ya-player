import 'package:flutter/material.dart';

import '/state_enums.dart';
import '/app_state.dart';
import '/audio_player.dart';
import '/controls/controls_bar.dart';
import '/controls/title_bar.dart';
import '/services/service_locator.dart';
import '/controls/main_menu.dart';
import 'main_screen.dart';
import 'app_loading_page.dart';
import 'login/login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final appState = getIt<AppState>();
  final audioPlayer = getIt<AudioPlayer>();

  _MainPageState() {
    appState.init();
  }

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
                page = const LoginPage();

              }
              else {
                page = _buildAppUi();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 32),
                child: page,
              );
            },
          ),
          const TitleBar(),
        ],
      )
    );
  }

  Column _buildAppUi() {
    return const Column(
      children: [
        Expanded(
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


