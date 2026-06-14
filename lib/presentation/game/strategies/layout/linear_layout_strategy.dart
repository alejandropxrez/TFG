import 'package:flame/components.dart';

import 'package:algoquest/domain/entities/structure_state.dart';
import 'layout_strategy.dart';

class LinearLayoutStrategy implements LayoutStrategy {
  const LinearLayoutStrategy();

  @override
  Map<String, Vector2> calculatePositions({
    required StructureState state,
    required Vector2 canvasSize,
  }) {
    final ids = state.nodes.keys.toList(growable: false);
    if (ids.isEmpty) return {};

    final spacing = canvasSize.x / (ids.length + 1);
    final y = canvasSize.y / 2;

    return {
      for (var i = 0; i < ids.length; i++)
        ids[i]: Vector2(spacing * (i + 1), y),
    };
  }
}
