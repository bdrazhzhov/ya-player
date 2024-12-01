import 'package:dbus/dbus.dart';

import '/services/service_locator.dart';

class SleepInhibitor {
  DBusValue? _blockCookie;

  final _inhibitorObject = DBusRemoteObject(
      getIt<DBusClient>(),
      name: 'org.freedesktop.PowerManagement.Inhibit',
      path: DBusObjectPath('/org/freedesktop/PowerManagement/Inhibit')
  );

  Future<void> blockSleep() async {
    if(_blockCookie != null) return;

    final DBusMethodSuccessResponse result = await _inhibitorObject.callMethod(
      'org.freedesktop.PowerManagement.Inhibit',
      'Inhibit',
      [DBusString('YaPlayer'), DBusString('Playing music...')]
    );

    _blockCookie = result.returnValues.first;
  }

  Future<void> unblockSleep() async {
    if(_blockCookie == null) return;

    await _inhibitorObject.callMethod(
      'org.freedesktop.PowerManagement.Inhibit',
      'UnInhibit', [_blockCookie!]
    );

    _blockCookie = null;
  }
}
