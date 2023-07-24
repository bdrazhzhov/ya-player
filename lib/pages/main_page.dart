import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/controls/main_menu.dart';
import 'package:ya_player/music_api.dart';

import '../app_state.dart';
import '../controls/controls_bar.dart';
import '../models/music_api/search.dart';
import '../services/service_locator.dart';
import 'main_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _appState = getIt<AppState>();
  bool isSearching = false;
  final searchFieldController = TextEditingController();

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
      child: Stack(
        children: [
          Column(
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
          ),
          TitleBar(),
        ],
      )
    );
  }
}

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Expanded(
            child: MoveWindow(
              child: Container(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: const Row(
                  children: [
                    Image(
                      image: AssetImage('assets/window_icon.png'),
                      filterQuality: FilterQuality.none,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Text('Window title'),
                    ),
                  ],
                ),
              ),
            )
          ),
          Row(
            children: [
              MinimizeWindowButton(),
              MaximizeWindowButton(),
              CloseWindowButton(),
            ],
          ),
        ]
      )
    );
  }
}
