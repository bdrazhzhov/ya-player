import 'dart:async';
import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

import 'dbus_menu_object.dart';

/// Category for notifier items.
enum StatusNotifierItemCategory {
  applicationStatus,
  communications,
  systemServices,
  hardware
}

/// Status for notifier items.
enum StatusNotifierItemStatus { passive, active }

String _encodeCategory(StatusNotifierItemCategory value) =>
    {
      StatusNotifierItemCategory.applicationStatus: 'ApplicationStatus',
      StatusNotifierItemCategory.communications: 'Communications',
      StatusNotifierItemCategory.systemServices: 'SystemServices',
      StatusNotifierItemCategory.hardware: 'Hardware'
    }[value] ??
    '';

String _encodeStatus(StatusNotifierItemStatus value) =>
    {
      StatusNotifierItemStatus.passive: 'Passive',
      StatusNotifierItemStatus.active: 'Active'
    }[value] ??
    '';

class _StatusNotifierItemObject extends DBusObject {
  final StatusNotifierItemCategory category;
  final String id;
  String _title;
  StatusNotifierItemStatus status;
  final int windowId;
  String iconName;
  String overlayIconName;
  String attentionIconName;
  String attentionMovieName;
  DBusObjectPath? menu;
  Future<void> Function(int x, int y)? onContextMenu;
  Future<void> Function(int x, int y)? onActivate;
  Future<void> Function(int x, int y)? onSecondaryActivate;
  Future<void> Function(int delta, String orientation)? onScroll;

  _StatusNotifierItemObject(
      {this.category = StatusNotifierItemCategory.applicationStatus,
      required this.id,
      title = '',
      this.status = StatusNotifierItemStatus.active,
      this.windowId = 0,
      this.iconName = '',
      this.overlayIconName = '',
      this.attentionIconName = '',
      this.attentionMovieName = '',
      this.menu,
      this.onContextMenu,
      this.onActivate,
      this.onSecondaryActivate,
      this.onScroll})
      : _title = title, super(DBusObjectPath('/StatusNotifierItem')) {
    menu ??= DBusObjectPath('/NO_DBUSMENU');
  }

  String get title => _title;
  set title(String value) {
    if(value == _title) return;

    _title = value;
    emitSignal('org.kde.StatusNotifierItem', 'NewTitle', []);
    emitPropertiesChanged(
      "org.kde.StatusNotifierItem",
      changedProperties: {"Title": DBusString(value)},
    );
  }

  late DBusStruct _dbusToolTip = DBusStruct([
    DBusString('YaPlayer'),
    DBusArray(DBusSignature('(iiay)'), []),
    DBusString('YaPlayer'),
    DBusString('')
  ]);
  Future<void> setToolTip(String title, String subtitle) async {
    _dbusToolTip = DBusStruct([
      DBusString('YaPlayer'),
      DBusArray(DBusSignature('(iiay)'), []),
      DBusString(title),
      DBusString(subtitle)
    ]);
    await emitNewToolTip();
    await emitPropertiesChanged(
      "org.kde.StatusNotifierItem",
      changedProperties: {"ToolTip": _dbusToolTip},
    );
  }

  /// Emits signal org.kde.StatusNotifierItem.NewIcon
  Future<void> emitNewIcon() async {
    await emitSignal('org.kde.StatusNotifierItem', 'NewIcon', []);
  }

  /// Emits signal org.kde.StatusNotifierItem.NewAttentionIcon
  Future<void> emitNewAttentionIcon() async {
    await emitSignal('org.kde.StatusNotifierItem', 'NewAttentionIcon', []);
  }

  /// Emits signal org.kde.StatusNotifierItem.NewOverlayIcon
  Future<void> emitNewOverlayIcon() async {
    await emitSignal('org.kde.StatusNotifierItem', 'NewOverlayIcon', []);
  }

  /// Emits signal org.kde.StatusNotifierItem.NewMenu
  Future<void> emitNewMenu() async {
    await emitSignal('org.kde.StatusNotifierItem', 'NewMenu', []);
  }

  /// Emits signal org.kde.StatusNotifierItem.NewToolTip
  Future<void> emitNewToolTip() async {
    await emitSignal('org.kde.StatusNotifierItem', 'NewToolTip', []);
  }

  /// Emits signal org.kde.StatusNotifierItem.NewStatus
  Future<void> emitNewStatus(String status) async {
    await emitSignal(
        'org.kde.StatusNotifierItem', 'NewStatus', [DBusString(status)]);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('org.freedesktop.StatusNotifierItem', methods: [
        DBusIntrospectMethod('ContextMenu', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y')
        ]),
        DBusIntrospectMethod('Activate', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y')
        ]),
        DBusIntrospectMethod('SecondaryActivate', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'x'),
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'y')
        ]),
        DBusIntrospectMethod('Scroll', args: [
          DBusIntrospectArgument(DBusSignature('i'), DBusArgumentDirection.in_,
              name: 'delta'),
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_,
              name: 'orientation')
        ]),
        // DBusIntrospectMethod('ProvideXdgActivationToken', args: [
        //   DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.in_,
        //       name: 'token')
        // ])
      ], signals: [
        DBusIntrospectSignal('NewTitle'),
        DBusIntrospectSignal('NewIcon'),
        DBusIntrospectSignal('NewAttentionIcon'),
        DBusIntrospectSignal('NewOverlayIcon'),
        DBusIntrospectSignal('NewMenu'),
        DBusIntrospectSignal('NewToolTip'),
        DBusIntrospectSignal('NewStatus', args: [
          DBusIntrospectArgument(DBusSignature('s'), DBusArgumentDirection.out,
              name: 'status')
        ])
      ], properties: [
        DBusIntrospectProperty('Category', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Id', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Title', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Status', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('WindowId', DBusSignature('i'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('IconName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('IconPixmap', DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('OverlayIconName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('OverlayIconPixmap', DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('AttentionIconName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('AttentionIconPixmap', DBusSignature('a(iiay)'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('AttentionMovieName', DBusSignature('s'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ToolTip', DBusSignature('(sa(iiay))'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('ItemIsMenu', DBusSignature('b'),
            access: DBusPropertyAccess.read),
        DBusIntrospectProperty('Menu', DBusSignature('o'),
            access: DBusPropertyAccess.read)
      ])
    ];
  }

  bool isInterfaceCorrect(String? interfaceName) {
    return interfaceName == 'org.freedesktop.StatusNotifierItem'
        || interfaceName == 'org.kde.StatusNotifierItem';
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (!isInterfaceCorrect(methodCall.interface)) {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'ContextMenu':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onContextMenu?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'Activate':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onActivate?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'SecondaryActivate':
        if (methodCall.signature != DBusSignature('ii')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var x = methodCall.values[0].asInt32();
        var y = methodCall.values[1].asInt32();
        await onSecondaryActivate?.call(x, y);
        return DBusMethodSuccessResponse();
      case 'Scroll':
        if (methodCall.signature != DBusSignature('is')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        var delta = methodCall.values[0].asInt32();
        var orientation = methodCall.values[1].asString();
        await onScroll?.call(delta, orientation);
        return DBusMethodSuccessResponse();
      // case 'ProvideXdgActivationToken':
      //   if (methodCall.signature != DBusSignature('s')) {
      //     return DBusMethodErrorResponse.invalidArgs();
      //   }
      //   return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    debugPrint('Requested $interface.$name');

    if (!isInterfaceCorrect(interface)) {
      return DBusMethodErrorResponse.unknownProperty();
    }

    switch (name) {
      case 'Category':
        return DBusGetPropertyResponse(DBusString(_encodeCategory(category)));
      case 'Id':
        return DBusGetPropertyResponse(DBusString(id));
      case 'Title':
        return DBusGetPropertyResponse(DBusString(title));
      case 'Status':
        return DBusGetPropertyResponse(DBusString(_encodeStatus(status)));
      case 'WindowId':
        return DBusGetPropertyResponse(DBusInt32(windowId));
      case 'IconName':
        return DBusGetPropertyResponse(DBusString(iconName));
      case 'IconPixmap':
        return DBusGetPropertyResponse(DBusArray(DBusSignature('(iiay)'), []));
      case 'OverlayIconName':
        return DBusGetPropertyResponse(DBusString(overlayIconName));
      case 'OverlayIconPixmap':
        return DBusGetPropertyResponse(DBusArray(DBusSignature('(iiay)'), []));
      case 'AttentionIconName':
        return DBusGetPropertyResponse(DBusString(attentionIconName));
      case 'AttentionIconPixmap':
        return DBusGetPropertyResponse(DBusArray(DBusSignature('(iiay)'), []));
      case 'AttentionMovieName':
        return DBusGetPropertyResponse(DBusString(attentionMovieName));
      case 'ToolTip':
        return DBusGetPropertyResponse(_dbusToolTip);
      case 'ItemIsMenu':
        return DBusGetPropertyResponse(DBusBoolean(false));
      case 'Menu':
        return DBusGetPropertyResponse(menu!);
      default:
        return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    return DBusGetAllPropertiesResponse({
      'Category': DBusString(_encodeCategory(category)),
      'Id': DBusString(id),
      'Title': DBusString(title),
      'Status': DBusString(_encodeStatus(status)),
      'WindowId': DBusInt32(windowId),
      'IconName': DBusString(iconName),
      'IconPixmap': DBusArray(DBusSignature('(iiay)'), []),
      'OverlayIconName': DBusString(overlayIconName),
      'OverlayIconPixmap': DBusArray(DBusSignature('(iiay)'), []),
      'AttentionIconName': DBusString(attentionIconName),
      'AttentionIconPixmap': DBusArray(DBusSignature('(iiay)'), []),
      'AttentionMovieName': DBusString(attentionMovieName),
      'ToolTip': _dbusToolTip,
      'ItemIsMenu': DBusBoolean(false),
      'Menu': menu!
    });
  }
}

/// A client that registers status notifier items.
class StatusNotifierItemClient {
  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  DBusMenuObject? _menuObject;
  late final _StatusNotifierItemObject _notifierItemObject;

  // FIXME: status enum
  /// Creates a new status notifier item client. If [bus] is provided connect to the given D-Bus server.
  StatusNotifierItemClient(
      {required String id,
      StatusNotifierItemCategory category =
          StatusNotifierItemCategory.applicationStatus,
      String title = '',
      StatusNotifierItemStatus status = StatusNotifierItemStatus.active,
      int windowId = 0,
      String iconName = '',
      String overlayIconName = '',
      String attentionIconName = '',
      String attentionMovieName = '',
      DBusMenuItem? menu,
      Future<void> Function(int x, int y)? onContextMenu,
      Future<void> Function(int x, int y)? onActivate,
      Future<void> Function(int x, int y)? onSecondaryActivate,
      Future<void> Function(int delta, String orientation)? onScroll,
      DBusClient? bus})
      : _bus = bus ?? DBusClient.session(),
        _closeBus = bus == null {
    if(menu != null) _menuObject = DBusMenuObject(DBusObjectPath('/Menu'), menu);
    _notifierItemObject = _StatusNotifierItemObject(
        id: id,
        category: category,
        title: title,
        status: status,
        windowId: windowId,
        iconName: iconName,
        overlayIconName: overlayIconName,
        attentionIconName: attentionIconName,
        attentionMovieName: attentionMovieName,
        menu: _menuObject?.path,
        onContextMenu: onContextMenu,
        onActivate: onActivate,
        onSecondaryActivate: onSecondaryActivate,
        onScroll: onScroll);
  }

  // Connect to D-Bus and register this notifier item.
  Future<void> connect() async {
    var name = 'org.kde.StatusNotifierItem-$pid-1';
    var requestResult = await _bus.requestName(name);
    assert(requestResult == DBusRequestNameReply.primaryOwner);

    // Register the menu.
    if(_menuObject != null) await _bus.registerObject(_menuObject!);

    // Put the item on the bus.
    await _bus.registerObject(_notifierItemObject);

    // Register the item.
    await _bus.callMethod(
        destination: 'org.kde.StatusNotifierWatcher',
        path: DBusObjectPath('/StatusNotifierWatcher'),
        interface: 'org.kde.StatusNotifierWatcher',
        name: 'RegisterStatusNotifierItem',
        values: [DBusString(name)],
        replySignature: DBusSignature.empty);
  }

  /// Updates the menu shown.
  Future<void> updateMenu(DBusMenuItem menu) async {
    await _menuObject?.update(menu);
  }

  void setTitle(String title) {
    _notifierItemObject.title = title;
  }

  void setToolTip(String title, String subtitle) {
    _notifierItemObject.setToolTip(title, subtitle);
  }

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    if (_closeBus) {
      await _bus.close();
    }
  }
}
