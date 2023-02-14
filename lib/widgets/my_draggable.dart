import 'package:flutter/material.dart';

class MyDraggable extends StatefulWidget {
  final Widget child;
  final Function(double, double) buildFeedback;
  double xStart = 0;
  double yStart = 0;
  double x = 0;
  double y = 0;
  final double childWidth;
  final double childHeight;
  final Function(double dx, double dy)? onDragUpdate;
  final Function(double dx, double dy)? onDragEnd;

  MyDraggable(
      {super.key, required this.child,
      required this.childWidth,
      required this.childHeight,
      this.onDragUpdate,
      this.onDragEnd,
      required this.buildFeedback});

  @override
  _MyDraggableState createState() => _MyDraggableState();
}

class _MyDraggableState extends State<MyDraggable> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(children: [
        LayoutBuilder(builder: (context, constraints) {
          if (widget.x == 0 && widget.y == 0) {
            return widget.child;
          }
          return Stack(
            children: [
              Positioned(
                left:
                    constraints.maxWidth / 2 - widget.childWidth / 2 + widget.x,
                top: constraints.maxHeight / 2 -
                    widget.childHeight / 2 +
                    widget.y,
                child: widget.buildFeedback(widget.x, widget.y),
              )
            ],
          );
        }),
      ]),
      onPanStart: (details) {
        widget.xStart = details.globalPosition.dx;
        widget.yStart = details.globalPosition.dy;
      },
      onPanUpdate: (details) {
        setState(() {
          widget.x = details.globalPosition.dx - widget.xStart;
          widget.y = details.globalPosition.dy - widget.yStart;
        });
        widget.onDragUpdate?.call(widget.x, widget.y);
      },
      onPanEnd: (details) {
        widget.onDragEnd?.call(widget.x, widget.y);
        setState(() {
          widget.x = 0;
          widget.y = 0;
        });
      },
    );
  }
}
