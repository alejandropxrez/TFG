import 'package:flame/components.dart';

import 'package:algoquest/domain/entities/structure_state.dart';

abstract class LayoutStrategy {
  Map<String, Vector2> calculatePositions({
    required StructureState state,
    required Vector2 canvasSize,
  });
}
