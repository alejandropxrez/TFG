import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class InventoryItemComponent extends RectangleComponent with TapCallbacks {
  final int value;
  final bool isSelected;
  final void Function(int value)? onTapInventoryItem;

  InventoryItemComponent({
    required this.value,
    required Vector2 position,
    this.isSelected = false,
    this.onTapInventoryItem,
    Vector2? size,
  }) : super(
         position: position,
         size: size ?? Vector2(56, 56),
         anchor: Anchor.center,
         paint: Paint()
           ..color = isSelected ? Colors.orangeAccent : Colors.deepPurpleAccent,
       );

  @override
  void onTapDown(TapDownEvent event) {
    onTapInventoryItem?.call(value);
  }

  @override
  void render(Canvas canvas) {
    paint.color = isSelected ? Colors.orangeAccent : Colors.deepPurpleAccent;

    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.8);

    canvas.drawRRect(rrect, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: const TextStyle(
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
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }
}
