import 'package:flutter/material.dart';

class PageSectionHeader extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const PageSectionHeader({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Text(title, style: Theme.of(context).textTheme.titleLarge);

    if (onPressed != null) {
      child = _InteractiveHeader(
        onPressed: onPressed!,
        child: child,
      );
    }

    return child;
  }
}

class _InteractiveHeader extends StatefulWidget {
  final Widget child;
  final void Function() onPressed;

  const _InteractiveHeader({required this.child, required this.onPressed});

  @override
  State<_InteractiveHeader> createState() => _InteractiveHeaderState();
}

class _InteractiveHeaderState extends State<_InteractiveHeader> {
  double padding = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => setState(() => padding = 6),
        onExit: (_) => setState(() => padding = 0),
        cursor: SystemMouseCursors.click,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            widget.child,
            AnimatedPadding(
              padding: EdgeInsetsGeometry.only(left: padding),
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
