import 'package:flutter/material.dart';

import '/services/context_menu_manager.dart';
import '/services/service_locator.dart';
import 'context_menu_item.dart';

class ContextMenu extends StatefulWidget {
  final List<MenuItem> items;
  final Widget child;

  const ContextMenu({super.key, required this.child, required this.items});

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  final contextMenuManager = getIt<ContextMenuManager>();
  int menuIndex = -1;
  Map<int,MenuItem> clickableItems = {};

  @override
  Widget build(BuildContext context) {
    if(menuIndex >= 0) {
      contextMenuManager.destroyMenu(menuIndex);
    }

    clickableItems = flattenItemsTree(widget.items);
    final items = widget.items.map((item) => item.toMap()).toList();
    contextMenuManager.createMenu(items, _itemClicked)
        .then((index) { menuIndex = index; });

    return GestureDetector(
      onTap: (){
        contextMenuManager.showContextMenu(menuIndex);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: widget.child,
      ),
    );
  }

  static Map<int,MenuItem> flattenItemsTree(List<MenuItem> items) {
    final Map<int,MenuItem> result = {};
    for(final MenuItem item in items) {
      result[item.id] = item;
      if(item.items.isNotEmpty) {
        final subItems = flattenItemsTree(item.items);
        result.addAll(subItems);
      }
    }
    return result;
  }

  @override
  void dispose() {
    contextMenuManager.destroyMenu(menuIndex);
    super.dispose();
  }

  void _itemClicked(int itemIndex) {
    final item = clickableItems[itemIndex];
    if(item?.onTap == null) return;

    item!.onTap!();
  }
}
