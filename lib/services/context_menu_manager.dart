import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final class ContextMenuManager {
  final _platform = MethodChannel('YaPlayerContextMenuManager/events');
  final Map<int, void Function(int)> _itemClickHandlers = {};

  ContextMenuManager() {
    _platform.setMethodCallHandler(_methodCallHandler);
  }

  Future<dynamic> _methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onMenuItemClicked':
        final [menuIndex, itemIndex] = methodCall.arguments as List<int>;
        _itemClickHandlers[menuIndex]!(itemIndex);
        break;
      default:
        debugPrint('Unknown method: ${methodCall.method}');
    }
  }

  Future<void> showContextMenu(int index) async {
    return _platform.invokeMethod('showMenu', index);
  }

  Future<int> createMenu(List<Map<String, dynamic>> menuItems,
      void Function(int) itemClickHandler) async {
    final index = await _platform.invokeMethod('createMenu', menuItems);
    _itemClickHandlers[index] = itemClickHandler;

    return index as int;
  }

  Future<void> destroyMenu(int index) async {
    _itemClickHandlers.remove(index);

    return _platform.invokeMethod('destroyMenu', index);
  }
}
