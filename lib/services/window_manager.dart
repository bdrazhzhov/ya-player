import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class WindowManager {
  final _platform = MethodChannel('YaPlayerWindowManager/events');

  final _backButtonStreamController = StreamController<bool>.broadcast();
  Stream<bool> get backButtonStream => _backButtonStreamController.stream;

  WindowManager() {
    _platform.setMethodCallHandler(_methodCallHandler);
  }

  Future<dynamic> _methodCallHandler(MethodCall methodCall) async {
    switch(methodCall.method) {
      case 'onBackButtonClicked':
        debugPrint('Back button pressed');
        _backButtonStreamController.add(true);
        break;
      default:
        debugPrint('Unknown method: ${methodCall.method}');
    }
  }

  Future<void> setWindowTitle(String title, String subTitle) async {
    return _platform.invokeMethod('setWindowTitle', [title, subTitle]);
  }

  Future<Color> getBgColor() async {
    int value = await _platform.invokeMethod('getBgColor');

    return Color(value);
  }

  Future<void> showBackButton(bool needToShow) async {
    return _platform.invokeMethod('showBackButton', needToShow);
  }

  Future<Map<String,Color>> getThemeColors() async {
    Map<Object?,Object?> result = await _platform.invokeMethod('getThemeColors');

    return {
      'surface': Color(result['surface'] as int),
      'textColor': Color(result['textColor'] as int),
    };
  }

  Future<void> showWindow() async {
    await _platform.invokeMethod('showWindow');
  }

  Future<void> setHideOnClose(bool hideOnClose) async {
    await _platform.invokeMethod('setHideOnClose', hideOnClose);
  }
}
