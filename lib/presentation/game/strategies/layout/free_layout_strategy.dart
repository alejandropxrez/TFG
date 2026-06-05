import 'dart:math';

import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/layout/layout_strategy.dart';
import 'package:flame/components.dart';

class FreeLayoutStrategy implements LayoutStrategy {
  static const double padding = 72.0;
  static const double spacingX = 96.0;
  static const double spacingY = 96.0;

  const FreeLayoutStrategy();

  @override
  Map<String, Vector2> calculatePositions({
    required StructureState state,
    required Vector2 canvasSize,
  }) {
    final nodeIds = state.nodes.keys.toList(growable: false);

    if (nodeIds.isEmpty) return {};

    final columns = max(1, ((canvasSize.x - padding * 2.0) / spacingX).floor());

    final positions = <String, Vector2>{};

    for (var i = 0; i < nodeIds.length; i++) {
      final row = i ~/ columns;
      final column = i % columns;

      positions[nodeIds[i]] = Vector2(
        padding + column * spacingX,
        padding + row * spacingY,
      );
    }

    return positions;
  }
}
