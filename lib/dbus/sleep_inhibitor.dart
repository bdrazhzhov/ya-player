import 'package:dbus/dbus.dart';

import '/services/service_locator.dart';

class SleepInhibitor {
  DBusValue? _blockCookie;
  static final interfaceName = 'org.freedesktop.PowerManagement.Inhibit';

  final _inhibitorObject = DBusRemoteObject(
    getIt<DBusClient>(),
    name: interfaceName,
    path: DBusObjectPath('/org/freedesktop/PowerManagement/Inhibit'),
  );

  Future<void> blockSleep() async {
    if (_blockCookie != null) return;

    final DBusMethodSuccessResponse result = await _inhibitorObject.callMethod(
      interfaceName,
      'Inhibit',
      [DBusString('YaPlayer'), DBusString('Playing music...')],
    );

    _blockCookie = result.returnValues.first;
  }

  Future<void> unblockSleep() async {
    if (_blockCookie == null) return;

    await _inhibitorObject.callMethod(interfaceName, 'UnInhibit', [_blockCookie!]);

    _blockCookie = null;
  }
}
