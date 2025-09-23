import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/controls/controls_bar.dart';
import '/controls/main_menu.dart';
import '/services/app_state.dart';
import '/services/audio_player.dart';
import '/services/service_locator.dart';
import '/services/state_enums.dart';
import 'app_loading_page.dart';
import 'login_page.dart';
import 'main_screen.dart';

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

            if (value == UiState.loading) {
              page = const AppLoadingPage();
            } else if (value == UiState.auth) {
              page = LoginPage();
            } else {
              page = _buildAppUi();
            }

            return page;
          },
        ),
        // const TitleBar(),
      ],
    ));
  }

  Widget _buildAppUi() {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (event.original?.kind == PointerDeviceKind.mouse &&
            event.original?.buttons == kBackMouseButton) {
          getIt<AppState>().navigateBack();
        }
      },
      child: Column(
        children: [
          const Expanded(
              child: Row(
            children: [MainMenu(), Expanded(child: MainScreen())],
          )),
          ControlsBar(isExpandable: true)
        ],
      ),
    );
  }
}
