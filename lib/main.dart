import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '/services/service_locator.dart';
import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  _initWindow();

  await setupServiceLocator();

  runApp(const MyApp());
}

void _initWindow() {
  windowManager.setPreventClose(true);
  
  WindowOptions windowOptions = WindowOptions(
    // size: Size(1080, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
