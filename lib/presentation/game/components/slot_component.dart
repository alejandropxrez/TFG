import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SlotComponent extends CircleComponent with TapCallbacks {
  final String slotId;
  final bool isSelected;
  final void Function(String slotId)? onTapSlot;

  SlotComponent({
    required this.slotId,
    required Vector2 position,
    this.isSelected = false,
    this.onTapSlot,
    double radius = 28,
  }) : super(
         radius: radius,
         position: position,
         anchor: Anchor.center,
         paint: Paint()
           ..color = isSelected
               ? Colors.orangeAccent
               : Colors.blueGrey.withValues(alpha: 0.45),
       );

  @override
  void onTapDown(TapDownEvent event) {
    onTapSlot?.call(slotId);
  }

  @override
  void render(Canvas canvas) {
    paint.color = isSelected
        ? Colors.orangeAccent
        : Colors.blueGrey.withValues(alpha: 0.45);

    super.render(canvas);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.8);

    canvas.drawCircle(Offset.zero, radius, borderPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
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
