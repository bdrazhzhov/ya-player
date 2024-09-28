import 'package:flutter/material.dart';

class PageLoadingIndicator extends StatelessWidget {
  const PageLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: const Center(
        child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator()
        ),
      ),
    );
  }
}
