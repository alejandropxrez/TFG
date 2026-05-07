import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NodeComponent extends CircleComponent {
  final String nodeId;
  final int? value;

  NodeComponent({
    required this.nodeId,
    required this.value,
    required Vector2 position,
    double radius = 28,
  }) : super(
         radius: radius,
         position: position,
         anchor: Anchor.center,
         paint: Paint()..color = Colors.blueAccent,
       );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      text: TextSpan(
        text: value?.toString() ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
