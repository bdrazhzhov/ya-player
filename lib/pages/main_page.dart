import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/controls/main_menu.dart';
import 'package:ya_player/helpers/app_route_observer.dart';
import 'package:ya_player/helpers/nav_keys.dart';

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
          const NavigationBack(),
          Expanded(
            child: MoveWindow(
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 4),
                    child: Image(
                      image: AssetImage('assets/window_icon.png'),
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text('Window title'),
                  ),
                ],
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

class NavigationBack extends StatefulWidget {
  const NavigationBack({super.key});

  @override
  State<NavigationBack> createState() => _NavigationBackState();
}

class _NavigationBackState extends State<NavigationBack> {
  Color backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: getIt<AppRouteObserver>().popNotifier,
      builder: (__, bool value, _) {
        if(value) {
          return GestureDetector(
            onTap: (){
              if(NavKeys.mainNav.currentState == null) return;

              backgroundColor = Colors.transparent;
              NavKeys.mainNav.currentState!.pop();
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (PointerEnterEvent event){
                backgroundColor = Colors.red;
                setState(() {});
              },
              onExit: (PointerExitEvent event){
                backgroundColor = Colors.transparent;
                setState(() {});
              },
              child: Container(
                width: 42,
                height: 32,
                decoration: BoxDecoration(color: backgroundColor),
                child: const Center(child: Icon(Icons.arrow_back))
              ),
            )
          );
        }
        else {
          return const SizedBox(width: 8);
        }
      },
    );
  }
}
