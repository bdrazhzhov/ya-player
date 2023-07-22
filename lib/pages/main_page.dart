import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/controls/main_menu.dart';

import '../app_state.dart';
import '../controls/controls_bar.dart';
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
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const MainMenu(),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 134, left: 32, right: 32),
                            child: const MainScreen()
                          ),
                          if(isSearching) ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 12.0,
                                sigmaY: 12.0,
                              ),
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 34, left: 34, right: 34),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(child: TextField()),
                                Checkbox(
                                  value: isSearching,
                                  onChanged: (value){
                                    setState(() {
                                      isSearching = value ?? false;
                                    });
                                  }
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
              const ControlsBar(isExpandable: true)
            ],
          ),
          const TitleBar(),
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
