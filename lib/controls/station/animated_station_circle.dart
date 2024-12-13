import 'package:flutter/material.dart';

class AnimatedStationCircle extends StatefulWidget {
  final Widget child;
  final Color color;
  final double maxWidth;

  const AnimatedStationCircle({
    super.key,
    required this.child,
    required this.color,
    required this.maxWidth
  });

  @override
  State<AnimatedStationCircle> createState() => _AnimatedStationCircleState();
}

class _AnimatedStationCircleState extends State<AnimatedStationCircle> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;

  @override
  void initState() {
    var duration = const Duration(milliseconds: 400);
    animationController = AnimationController(vsync: this, duration: duration)
      ..repeat(reverse: true);

    animation =  Tween(begin: widget.maxWidth, end: widget.maxWidth * 0.85)
        .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.decelerate
    )
    )..addListener(() => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.maxWidth,
      child: Center(
        child: SizedBox.square(
          dimension: animation.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
