import 'package:flutter/material.dart';

base class MenuItem {
  final String label;
  final IconData? icon;
  final List<MenuItem> items;
  late final int id;
  final void Function()? onTap;
  static int _idCounter = 0;

  bool get enabled => onTap != null || items.isNotEmpty;

  MenuItem({
    required this.label,
    this.icon,
    this.items = const [],
    this.onTap,
  }) {
    id = _idCounter;
    _idCounter += 1;
  }

  @override
  String toString() {
    return 'MenuItem{id: $id, label: $label, icon: $icon, enabled: $enabled}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'icon': icon?.codePoint,
      'enabled': enabled,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
