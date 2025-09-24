import 'package:flutter/material.dart';

import 'main_app.dart';
import 'services/app_state.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FutureBuilder.debugRethrowError = true;

  await setupServiceLocator();
  await getIt<AppState>().initTheme();
  getIt<AppState>().init();

  runApp(MyApp());
}
