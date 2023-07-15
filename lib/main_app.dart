import 'package:flutter/material.dart';
import 'package:ya_player/pages/main_page.dart';

import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.black54),
        useMaterial3: true,
        brightness: Brightness.dark
      ),
      // home: const SafeArea(
      //     child: MyHomePage(title: 'Flutter Demo Home Page')
      // ),
      home: const SafeArea(child: MainPage())
    );
  }
}
