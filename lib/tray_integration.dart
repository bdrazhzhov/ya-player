import 'package:dbus/dbus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xdg_status_notifier_item/xdg_status_notifier_item.dart';

import 'services/service_locator.dart';

final class TrayIntegration with WindowListener {
  late final StatusNotifierItemClient _trayIcon = StatusNotifierItemClient(
    id: 'YaPlayer',
    iconName: 'media-playback-start',
    bus: getIt<DBusClient>(),
    menu: DBusMenuItem(children: [
      DBusMenuItem(label: 'Show', onClicked: () => windowManager.show()),
      DBusMenuItem.separator(),
      DBusMenuItem(
        label: 'Quit',
        onClicked: () async => windowManager.destroy()
      ),
    ]));

  void init() async {
    await _trayIcon.connect();
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    windowManager.hide();
  }
}
