import 'dart:math';

import 'package:flame/components.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'components/edge_component.dart';
import 'components/node_component.dart';

class VisualScene {
  final List<Component> components;

  const VisualScene(this.components);
}

class VisualSceneBuilder {
  const VisualSceneBuilder();

  VisualScene build({
    required ChallengeSpec spec,
    required StructureState state,
    required Vector2 canvasSize,
    String? selectedNodeId,
    void Function(String nodeId)? onTapNode,
  }) {
    final positions = _buildTreePositions(state: state, canvasSize: canvasSize);

    final components = <Component>[];

    for (final edge in state.edges) {
      final start = positions[edge.source];
      final end = positions[edge.target];

      if (start != null && end != null) {
        components.add(EdgeComponent(start: start, end: end));
      }
    }

    for (final entry in state.nodes.entries) {
      final position = positions[entry.key];
      if (position == null) continue;

      components.add(
        NodeComponent(
          nodeId: entry.key,
          value: entry.value.value,
          position: position,
          isSelected: selectedNodeId == entry.key,
          onTapNode: onTapNode,
        ),
      );
    }

    return VisualScene(components);
  }

  Map<String, Vector2> _buildTreePositions({
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
