import 'package:flutter/material.dart';

class SliversContainer extends StatelessWidget {
  final List<Widget> slivers;

  const SliversContainer({super.key, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: slivers.map((e) => SliverPadding(
        padding: const EdgeInsets.only(left: 32, right: 32),
        sliver: e,
      )).toList(),
    );
  }
}
