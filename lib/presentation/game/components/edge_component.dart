import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class EdgeComponent extends PositionComponent with TapCallbacks {
  final Vector2 start;
  final Vector2 end;
  final String? sourceNodeId;
  final String? targetNodeId;
  final void Function(String sourceNodeId, String targetNodeId)? onTapEdge;

  EdgeComponent({
    required this.start,
    required this.end,
    this.sourceNodeId,
    this.targetNodeId,
    this.onTapEdge,
  }) : super(position: Vector2.zero(), size: Vector2.zero());

  @override
  bool containsLocalPoint(Vector2 point) {
    const tapTolerance = 14.0;

    final distance = _distanceFromPointToSegment(
      point: point,
      segmentStart: start,
      segmentEnd: end,
    );

    return distance <= tapTolerance;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final source = sourceNodeId;
    final target = targetNodeId;

    if (source == null || target == null) return;

    onTapEdge?.call(source, target);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
  }

  double _distanceFromPointToSegment({
    required Vector2 point,
    required Vector2 segmentStart,
    required Vector2 segmentEnd,
  }) {
    final dx = segmentEnd.x - segmentStart.x;
    final dy = segmentEnd.y - segmentStart.y;

    if (dx == 0 && dy == 0) {
      return point.distanceTo(segmentStart);
    }

    final t = max(
      0.0,
      min(
        1.0,
        ((point.x - segmentStart.x) * dx + (point.y - segmentStart.y) * dy) /
            (dx * dx + dy * dy),
      ),
    );

    final projection = Vector2(
      segmentStart.x + t * dx,
      segmentStart.y + t * dy,
    );

    return point.distanceTo(projection);
  }
}
