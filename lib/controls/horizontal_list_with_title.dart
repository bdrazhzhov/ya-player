import 'package:flutter/material.dart';

class HorizontalListWithTitle extends StatefulWidget {
  final Iterable<Widget> children;
  final Widget? title;
  final double itemWidth;
  final double spacing;

  const HorizontalListWithTitle({
    super.key,
    required this.children,
    this.itemWidth = 200.0,
    this.spacing = 0,
    this.title,
  });

  @override
  State<HorizontalListWithTitle> createState() => _HorizontalListWithTitleState();
}

class _HorizontalListWithTitleState extends State<HorizontalListWithTitle> {
  final ScrollController scrollController = ScrollController();
  bool enableLeft = false;
  bool enableRight = false;
  double? prevWidth;
  double scrollAmount = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(updateButtons);
  }

  @override
  void dispose() {
    scrollController.removeListener(updateButtons);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Row(
          children: [
            Expanded(child: widget.title ?? SizedBox.shrink()),
            if (enableLeft || enableRight)
              Row(
                spacing: 8,
                children: [
                  buildScrollButton(
                    icon: Icons.chevron_left,
                    onPressed: enableLeft ? () => scrollBy(-scrollAmount) : null,
                  ),
                  buildScrollButton(
                    icon: Icons.chevron_right,
                    onPressed: enableRight ? () => scrollBy(scrollAmount) : null,
                  ),
                ],
              ),
          ],
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final double? width = context.size?.width;
              if (width != null && width != prevWidth) {
                prevWidth = width;
                final itemWidth = widget.itemWidth + widget.spacing;
                scrollAmount = (width / itemWidth).toInt() * itemWidth;
                updateButtons();
              }
            });

            return SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: widget.spacing,
                children: widget.children.toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  void updateButtons() {
    if (!mounted) return;

    final maxExtent = scrollController.position.maxScrollExtent;
    final offset = scrollController.offset;

    final canScroll = maxExtent > 0.0;
    final shouldEnableLeft = canScroll && offset > 0.5;
    final shouldEnableRight = canScroll && offset < (maxExtent - 0.5);

    if (shouldEnableLeft != enableLeft || shouldEnableRight != enableRight) {
      enableLeft = shouldEnableLeft;
      enableRight = shouldEnableRight;
      setState(() {});
    }
  }

  void scrollBy(double delta) {
    final maxExtent = scrollController.position.maxScrollExtent;
    final target = (scrollController.offset + delta).clamp(0.0, maxExtent);
    scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget buildScrollButton({required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
