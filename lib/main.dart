import 'package:flutter/material.dart';
import 'package:ya_player/services/service_locator.dart';

import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}
