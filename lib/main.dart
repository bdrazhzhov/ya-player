import 'package:flutter/material.dart';

import 'services/service_locator.dart';
import 'services/app_state.dart';
import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();
  await getIt<AppState>().initTheme();
  getIt<AppState>().init();

  runApp(MyApp());
}
