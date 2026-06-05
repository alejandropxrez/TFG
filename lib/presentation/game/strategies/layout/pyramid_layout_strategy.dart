import 'dart:math';

import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/layout/layout_strategy.dart';
import 'package:flame/components.dart';

class PyramidLayoutStrategy implements LayoutStrategy {
  static const double horizontalPadding = 48.0;
  static const double topPadding = 64.0;
  static const double bottomPadding = 64.0;
  static const double minVerticalSpacing = 72.0;
  static const double maxVerticalSpacing = 120.0;

  const PyramidLayoutStrategy();

  @override
  Map<String, Vector2> calculatePositions({
    required StructureState state,
    required Vector2 canvasSize,
  }) {
    if (state.nodes.isEmpty) return {};

    final rootId = _findRootId(state);
    if (rootId == null) return _fallbackLinearPositions(state, canvasSize);

    final children = _buildChildrenMap(state);
    final maxDepth = _calculateMaxDepth(rootId, children);

    final availableHeight = max(0.0, canvasSize.y - topPadding - bottomPadding);

    final verticalSpacing = maxDepth == 0
        ? 0.0
        : (availableHeight / maxDepth).clamp(
            minVerticalSpacing,
            maxVerticalSpacing,
          );

    final minX = min(horizontalPadding, canvasSize.x / 2);
    final maxX = max(minX, canvasSize.x - horizontalPadding);

    final positions = <String, Vector2>{};

    void place(String nodeId, int depth, double left, double right) {
      final double x = (left + right) / 2.0;
      final double y = topPadding + depth * verticalSpacing;

      positions[nodeId] = Vector2(x, y);

      final nodeChildren = children[nodeId] ?? const <String>[];
      if (nodeChildren.isEmpty) return;

      final segmentWidth = (right - left) / max(1, nodeChildren.length);

      for (var i = 0; i < nodeChildren.length; i++) {
        final childLeft = left + i * segmentWidth;
        final childRight = left + (i + 1) * segmentWidth;

        place(nodeChildren[i], depth + 1, childLeft, childRight);
      }
    }

    place(rootId, 0, minX, maxX);

    return positions;
  }

  Map<String, List<String>> _buildChildrenMap(StructureState state) {
    final children = <String, List<String>>{};

    for (final edge in state.edges) {
      if (!state.nodes.containsKey(edge.source)) continue;
      if (!state.nodes.containsKey(edge.target)) continue;

      children.putIfAbsent(edge.source, () => []).add(edge.target);
    }

    return children;
  }

  int _calculateMaxDepth(String rootId, Map<String, List<String>> children) {
    var maxDepth = 0;

    void visit(String nodeId, int depth) {
      maxDepth = max(maxDepth, depth);

      for (final childId in children[nodeId] ?? const <String>[]) {
        visit(childId, depth + 1);
      }
    }

    visit(rootId, 0);

    return maxDepth;
  }

  String? _findRootId(StructureState state) {
    final allNodeIds = state.nodes.keys.toSet();
    final childIds = state.edges.map((edge) => edge.target).toSet();

    final roots = allNodeIds.difference(childIds);

    if (roots.length != 1) return null;

    return roots.first;
  }

  Map<String, Vector2> _fallbackLinearPositions(
    StructureState state,
    Vector2 canvasSize,
  ) {
    final ids = state.nodes.keys.toList(growable: false);
    if (ids.isEmpty) return {};

    final spacing = canvasSize.x / (ids.length + 1);
    final y = canvasSize.y / 2.0;

    return {
      for (var i = 0; i < ids.length; i++)
        ids[i]: Vector2(spacing * (i + 1), y),
    };
  }
}
