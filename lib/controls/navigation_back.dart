import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../helpers/app_route_observer.dart';
import '../helpers/nav_keys.dart';
import '../services/service_locator.dart';

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
                NavigatorState? navState = NavKeys.mainNav.currentState;
                navState ??= NavKeys.loginNav.currentState;
                if(navState == null) return;

                backgroundColor = Colors.transparent;
                navState.pop();
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
