import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class NodeComponent extends CircleComponent with TapCallbacks {
  final String nodeId;
  final int? value;
  final void Function(String nodeId)? onTapNode;

  bool isSelected;

  NodeComponent({
    required this.nodeId,
    required this.value,
    required Vector2 position,
    this.onTapNode,
    this.isSelected = false,
    double radius = 28,
  }) : super(
         radius: radius,
         position: position,
         anchor: Anchor.center,
         paint: Paint()
           ..color = isSelected ? Colors.orangeAccent : Colors.blueAccent,
       );

  @override
  void onTapDown(TapDownEvent event) {
    onTapNode?.call(nodeId);
  }

  @override
  void render(Canvas canvas) {
    paint.color = isSelected ? Colors.orangeAccent : Colors.blueAccent;

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
