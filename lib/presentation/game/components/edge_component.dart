import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EdgeComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;

  EdgeComponent({required this.start, required this.end});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3;

    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }
}
