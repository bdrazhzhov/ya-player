import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '/app_state.dart';
import '/services/service_locator.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final appState = getIt<AppState>();
  bool isAuthOpened = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: isAuthOpened ? null : startLogin,
        child: Text('Login'),
      )
    );
  }

  void startLogin() async {
    isAuthOpened = true;
    setState(() {});

    final result = await Process.run(join(dirname(Platform.resolvedExecutable), 'yandex-auth'), []);
    isAuthOpened = false;
    setState(() {});

    final String authToken = result.stdout.toString().split('\n').firstOrNull ?? '';

    if(authToken.isEmpty) {
      debugPrint('Empty auth token');
      return;
    }

    appState.login(authToken);
  }
}
