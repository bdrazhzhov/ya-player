import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tray_manager/tray_manager.dart';

import 'pages/main_page.dart';

class MyApp extends StatelessWidget with TrayListener {
  MyApp({super.key}) {
    trayManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark
      ),
      home: const SafeArea(child: MainPage())
    );
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      appWindow.show();
    } else if (menuItem.key == 'hide_window') {
      appWindow.hide();
    } else if (menuItem.key == 'exit_app') {
      appWindow.close();
    }
  }
}
