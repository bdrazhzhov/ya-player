import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/app_state.dart';
import '/services/service_locator.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final appState = getIt<AppState>();
  final _platform = MethodChannel('YaPlayerAuthManager/events');
  bool isAuthOpened = false;

  _LoginPageState() {
    _platform.setMethodCallHandler(_methodCallHandler);
  }

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
    _platform.invokeMethod('openAuthWindow');
  }

  Future<dynamic> _methodCallHandler(MethodCall methodCall) async {
    switch(methodCall.method) {
      case 'onAuthCompleted':
        isAuthOpened = false;
        setState(() {});


        final Map<String,String> data = methodCall.arguments.cast<String,String>();

        if(!data.keys.contains('accessToken')) {
          debugPrint('Empty auth token');
          return;
        }

        appState.login(data['accessToken']!);
        break;
      default:
        debugPrint('Unknown method: ${methodCall.method}');
    }
  }
}
