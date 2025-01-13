import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_state.dart';
import 'pages/main_page.dart';
import 'services/service_locator.dart';

class MyApp extends StatelessWidget {
  final _appState = getIt<AppState>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appState.themeNotifier,
      builder: (_, ThemeData theme, __) {
        return MaterialApp(
          title: 'YaPlayer',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme,
          home: MainPage()
        );
      },
    );
  }
}
