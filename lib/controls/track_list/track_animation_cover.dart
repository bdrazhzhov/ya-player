import 'package:flutter/material.dart';

class TrackAnimationCover extends StatefulWidget {
  final Color bgColor;
  final double radius;
  final bool playAnimation;

  const TrackAnimationCover({
    super.key,
    required this.bgColor,
    required this.radius,
    this.playAnimation = false,
  });

  @override
  State<TrackAnimationCover> createState() => _TrackAnimationCoverState();
}

class _TrackAnimationCoverState extends State<TrackAnimationCover>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    animationController.repeat(reverse: true);
    animation = Tween(begin: 10.0, end: widget.radius).animate(animationController)
      ..addListener(() => setState(() {}));

    if (!widget.playAnimation) animationController.stop();

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: animation.value,
      height: animation.value,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
        ),
      ),
    );
  }
}
