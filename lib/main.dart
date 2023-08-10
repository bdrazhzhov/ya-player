import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/services/service_locator.dart';

import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());

  if(!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    doWhenWindowReady(() {
      const initialSize = Size(1024, 768);
      appWindow.minSize = const Size(370, 512);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = 'YaPlayer';
      appWindow.show();
    });
  }
}
