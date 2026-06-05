import 'dart:math';

import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/layout/layout_strategy.dart';
import 'package:flame/components.dart';

class CircularLayoutStrategy implements LayoutStrategy {
  static const double padding = 72.0;

  const CircularLayoutStrategy();

  @override
  Map<String, Vector2> calculatePositions({
    required StructureState state,
    required Vector2 canvasSize,
  }) {
    final nodeIds = state.nodes.keys.toList(growable: false);

    if (nodeIds.isEmpty) return {};

    final center = Vector2(canvasSize.x / 2.0, canvasSize.y / 2.0);

    if (nodeIds.length == 1) {
      return {nodeIds.single: center};
    }

    final radius = max(24.0, min(canvasSize.x, canvasSize.y) / 2.0 - padding);

    final positions = <String, Vector2>{};

    for (var i = 0; i < nodeIds.length; i++) {
      final angle = -pi / 2.0 + (2.0 * pi * i / nodeIds.length);

      positions[nodeIds[i]] = Vector2(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle),
      );
    }

    return positions;
  }
}
