import 'package:flutter/material.dart';

import '/helpers/bitsdojo_window/window_button.dart';
import '/helpers/bitsdojo_window/window_caption.dart';
import 'navigation_back.dart';

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
