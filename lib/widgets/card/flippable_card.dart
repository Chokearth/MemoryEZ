import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_ez/widgets/card/card_face.dart';

class FlippableCard extends StatelessWidget {
  final CardFaceContentParameters front;
  final CardFaceContentParameters back;
  final Color borderColor;
  final bool isFront;
  final VoidCallback? onTap;
  final Duration duration;

  const FlippableCard({
    Key? key,
    required this.front,
    required this.back,
    required this.isFront,
    this.duration = const Duration(milliseconds: 400),
    this.borderColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: _transitionBuilder,
      layoutBuilder: (widget, list) => Stack(
        children: [widget!, ...list],
      ),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeIn.flipped,
      child: CardFace(
        key: ValueKey(isFront),
        faceParameter: isFront ? front : back,
        borderColor: borderColor,
        onTap: onTap,
      ),
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    final rotateAnimation =
        Tween<double>(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnimation,
      builder: (context, child) {
        final isUnder = const ValueKey(true) != child!.key;
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1 : 1;
        final value = min(rotateAnimation.value, pi / 2);

        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
