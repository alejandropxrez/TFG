import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class EdgeComponent extends PositionComponent with TapCallbacks {
  final Vector2 start;
  final Vector2 end;
  final String? sourceNodeId;
  final String? targetNodeId;
  final bool isCurved;
  final void Function(String sourceNodeId, String targetNodeId)? onTapEdge;

  EdgeComponent({
    required this.start,
    required this.end,
    this.sourceNodeId,
    this.targetNodeId,
    this.onTapEdge,
    this.isCurved = false,
  }) : super(position: Vector2.zero(), size: Vector2.zero());

  @override
  bool containsLocalPoint(Vector2 point) {
    const tapTolerance = 14.0;

    if (isCurved) {
      return _isPointNearCurve(point: point, tolerance: tapTolerance);
    }

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
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (isCurved) {
      final control = _controlPoint();

      final path = Path()
        ..moveTo(start.x, start.y)
        ..quadraticBezierTo(control.x, control.y, end.x, end.y);

      canvas.drawPath(path, paint);
      return;
    }

    canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
  }

  Vector2 _controlPoint() {
    final mid = (start + end) / 2;

    final direction = end - start;

    if (direction.length2 == 0) {
      return mid;
    }

    final normal = Vector2(-direction.y, direction.x)..normalize();

    const curveHeight = 72.0;

    return mid + normal * curveHeight;
  }

  bool _isPointNearCurve({required Vector2 point, required double tolerance}) {
    const samples = 24;

    var previous = start;

    for (var i = 1; i <= samples; i++) {
      final t = i / samples;
      final current = _quadraticPoint(t);

      final distance = _distanceFromPointToSegment(
        point: point,
        segmentStart: previous,
        segmentEnd: current,
      );

      if (distance <= tolerance) {
        return true;
      }

      previous = current;
    }

    return false;
  }

  Vector2 _quadraticPoint(double t) {
    final control = _controlPoint();

    final oneMinusT = 1 - t;

    return start * (oneMinusT * oneMinusT) +
        control * (2 * oneMinusT * t) +
        end * (t * t);
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
