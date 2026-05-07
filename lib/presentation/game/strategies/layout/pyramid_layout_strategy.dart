import 'dart:math';

import 'package:flame/components.dart';

import '../../../../domain/entities/structure_state.dart';
import 'layout_strategy.dart';

class PyramidLayoutStrategy implements LayoutStrategy {
  const PyramidLayoutStrategy();

  @override
  Map<String, Vector2> calculatePositions({
    required StructureState state,
    required Vector2 canvasSize,
  }) {
    final rootId = _findRootId(state);
    if (rootId == null) return {};

    final children = <String, List<String>>{};

    for (final edge in state.edges) {
      children.putIfAbsent(edge.source, () => []).add(edge.target);
    }

    final positions = <String, Vector2>{};

    void place(String nodeId, int depth, double minX, double maxX) {
      final x = (minX + maxX) / 2;
      final double y = 80 + depth * 100;

      positions[nodeId] = Vector2(x, y);

      final nodeChildren = children[nodeId] ?? const [];

      if (nodeChildren.isEmpty) return;

      final segment = (maxX - minX) / max(1, nodeChildren.length);

      for (var i = 0; i < nodeChildren.length; i++) {
        place(
          nodeChildren[i],
          depth + 1,
          minX + i * segment,
          minX + (i + 1) * segment,
        );
      }
    }

    place(rootId, 0, 40, canvasSize.x - 40);

    return positions;
  }

  String? _findRootId(StructureState state) {
    final allNodeIds = state.nodes.keys.toSet();
    final childIds = state.edges.map((e) => e.target).toSet();

    final roots = allNodeIds.difference(childIds);

    if (roots.isEmpty) return null;

    return roots.first;
  }
}
