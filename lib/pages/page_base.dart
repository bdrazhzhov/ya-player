import 'package:flutter/material.dart';

class PageBase extends StatelessWidget {
  final String title;
  final List<Widget> slivers;

  const PageBase({
    super.key,
    required this.title,
    required this.slivers
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 25, bottom: 50),
            sliver: SliverToBoxAdapter(
              child: Text(title, style: theme.textTheme.displayMedium)
            ),
          ),
          ...slivers.map((sliver) => SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32),
              sliver: sliver
            )
          )
        ]
      ),
    );
  }
}
