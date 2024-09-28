import 'package:flutter/material.dart';

class CustomSeparatedHList extends StatelessWidget {
  CustomSeparatedHList({
    super.key,
    required Iterable<Widget> children,
    required Widget separatorWidget,
  }) {
    for (var i = 0; i < children.length; i++) {
      _widgets.add(children.elementAt(i));

      if(i == children.length - 1) return;

      _widgets.add(separatorWidget);
    }
  }

  final List<Widget> _widgets = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _widgets.toList(),
      )
    );
  }
}
