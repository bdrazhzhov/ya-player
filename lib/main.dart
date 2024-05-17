import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:ya_player/services/service_locator.dart';

import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(MyApp());

  if(!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    doWhenWindowReady(() {
      initSystemTray();
      const initialSize = Size(1024, 768);
      appWindow.minSize = const Size(370, 512);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = 'YaPlayer';
      appWindow.show();
    });
  }
}

Future<void> initSystemTray() async {
  await trayManager.setIcon('assets/app_icon.png');
  Menu menu = Menu(
    items: [
      MenuItem(key: 'show_window', label: 'Show Window'),
      MenuItem(key: 'hide_window', label: 'Hide Window'),
      MenuItem.separator(),
      MenuItem(key: 'exit_app', label: 'Exit App'),
    ],
  );
  await trayManager.setContextMenu(menu);
}
