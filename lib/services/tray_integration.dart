import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

import '/dbus/status_notifier_item/dbus_menu_object.dart';
import '/dbus/status_notifier_item/status_notifier_item_client.dart';
import 'service_locator.dart';
import 'window_manager.dart';

enum PlayBackChangeType {playPause, next, prev}

final class TrayIntegration
{
  final _windowManager = getIt<WindowManager>();

  late final StatusNotifierItemClient _trayIcon;

  final _playBackChangeController = StreamController<PlayBackChangeType>.broadcast();
  Stream<PlayBackChangeType> get playBackChangeStream => _playBackChangeController.stream;

  final _scrollController = StreamController<int>.broadcast();
  Stream<int> get scrollStream => _scrollController.stream;

  void init() async {
    _trayIcon = StatusNotifierItemClient(
      id: 'YaPlayer',
      iconName: await _iconName(),
      title: 'YaPlayer',
      bus: getIt<DBusClient>(),
      menu: DBusMenuItem(children: [
        DBusMenuItem(label: 'Show', onClicked: () => _windowManager.showWindow()),
        DBusMenuItem.separator(),
        DBusMenuItem(
            label: 'Play/Pause',
            onClicked: () async => _playBackChangeController.add(PlayBackChangeType.playPause)),
        DBusMenuItem(
            label: 'Next',
            iconName: 'media-skip-forward',
            onClicked: () async => _playBackChangeController.add(PlayBackChangeType.next)),
        DBusMenuItem(
            label: 'Previous',
            iconName: 'media-skip-backward',
            onClicked: () async => _playBackChangeController.add(PlayBackChangeType.prev)),
        DBusMenuItem.separator(),
        DBusMenuItem(label: 'Quit', onClicked: () => exit(0)),
      ]),
      onActivate: (x, y) async => _playBackChangeController.add(PlayBackChangeType.playPause),
      onSecondaryActivate: (x, y) async => debugPrint('OnSecondaryActivate: $x, $y'),
      onScroll: (delta, _) async => _scrollController.add(delta),
    );
    await _trayIcon.connect();
  }

  Future<String> _iconName() async {
    final Brightness type = await _windowManager.getThemeType();
    if (type == Brightness.light) {
      return 'y_icon_thin_light';
    } else {
      return 'y_icon_thin_dark';
    }
  }

  void setTitle(String title) {
    _trayIcon.setTitle(title);
  }

  void setTooltip(String title, String subtitle) {
    _trayIcon.setToolTip(title, subtitle);
  }
}
