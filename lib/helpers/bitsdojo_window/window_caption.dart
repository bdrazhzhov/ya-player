import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';

import 'app_window.dart';

class _MoveWindow extends StatelessWidget {
  const _MoveWindow({this.child, this.onDoubleTap});
  final Widget? child;
  final VoidCallback? onDoubleTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        onDoubleTap: onDoubleTap ?? () => windowManager.maximize(),
        child: child ?? Container());
  }
}

class MoveWindow extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onDoubleTap;
  const MoveWindow({super.key, this.child, this.onDoubleTap});
  @override
  Widget build(BuildContext context) {
    if (child == null) return _MoveWindow(onDoubleTap: onDoubleTap);
    return _MoveWindow(
      onDoubleTap: onDoubleTap,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: child!)]),
    );
  }
}

class WindowTitleBarBox extends StatelessWidget {
  final Widget? child;
  const WindowTitleBarBox({super.key, this.child});
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container();
    }
    final titleBarHeight = appWindow.titleBarHeight;
    return SizedBox(height: titleBarHeight, child: child ?? SizedBox.shrink());
  }
}
