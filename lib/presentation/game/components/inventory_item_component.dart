import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class InventoryItemComponent extends RectangleComponent
    with TapCallbacks, DragCallbacks {
  final int value;
  final bool isSelected;
  final void Function(int value)? onTapInventoryItem;

  final void Function(int value, Vector2 position)? onDragStartItem;
  final void Function(int value, Vector2 position)? onDragUpdateItem;
  final void Function(int value, Vector2 position)? onDragEndItem;

  Vector2? _initialPosition;

  InventoryItemComponent({
    required this.value,
    required Vector2 position,
    this.isSelected = false,
    this.onTapInventoryItem,
    this.onDragStartItem,
    this.onDragUpdateItem,
    this.onDragEndItem,
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
    super.onTapDown(event);
    onTapInventoryItem?.call(value);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _initialPosition = position.clone();
    onDragStartItem?.call(value, position.clone());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    onDragUpdateItem?.call(value, position.clone());
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final dropPosition = position.clone();

    // Reset visual position locally. If the drop is valid, Riverpod will update
    // the game state and the scene will rebuild naturally.
    if (_initialPosition != null) position = _initialPosition!.clone();
    _initialPosition = null;

    onDragEndItem?.call(value, dropPosition);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (_initialPosition != null) position = _initialPosition!.clone();
    _initialPosition = null;
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
