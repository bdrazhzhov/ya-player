import 'package:flutter/material.dart';

import '../app_state.dart';
import '../controls/controls_bar.dart';
// import '../controls/title_bar.dart';
import '../services/service_locator.dart';
import '../controls/main_menu.dart';
import 'main_screen.dart';
import 'app_loading_page.dart';
import 'login/login_page.dart';

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
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _appState.mainPageState,
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

              return page;
            },
          ),
          // const TitleBar(),
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


