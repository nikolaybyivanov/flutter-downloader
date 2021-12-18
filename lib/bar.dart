import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  final double position;
  final GestureDragStartCallback onHorizontalDragStart;
  final GestureDragUpdateCallback onHorizontalDragUpdate;
  final GestureDragEndCallback onHorizontalDragEnd;

  Bar({
    required this.position,
    required this.onHorizontalDragStart,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: position >= 0.0 ? position : 0.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: onHorizontalDragStart,
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        onHorizontalDragEnd: onHorizontalDragEnd,
        child: Container(
          color: Colors.red,
          height: 200.0,
          width: 5.0,
        ),
      ),
    );
  }
}
