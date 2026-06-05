import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/presentation/game/strategies/layout/free_layout_strategy.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StructureState buildState({required List<String> nodeIds}) {
    return StructureState.fromNodesAndEdges(
      type: StructureType.graph,
      nodes: [for (final id in nodeIds) NodeState(id: id, value: null)],
      edges: const [],
    );
  }

  test('returns empty positions when there are no nodes', () {
    final strategy = const FreeLayoutStrategy();

    final positions = strategy.calculatePositions(
      state: buildState(nodeIds: const []),
      canvasSize: Vector2(400, 300),
    );

    expect(positions, isEmpty);
  });

  test('returns one position for each node', () {
    final strategy = const FreeLayoutStrategy();

    final positions = strategy.calculatePositions(
      state: buildState(nodeIds: const ['n1', 'n2', 'n3']),
      canvasSize: Vector2(400, 300),
    );

    expect(positions.keys, containsAll(['n1', 'n2', 'n3']));
    expect(positions.length, 3);
  });

  test('keeps positions non-negative even on small canvas', () {
    final strategy = const FreeLayoutStrategy();

    final positions = strategy.calculatePositions(
      state: buildState(nodeIds: const ['n1', 'n2']),
      canvasSize: Vector2(80, 80),
    );

    for (final position in positions.values) {
      expect(position.x, greaterThanOrEqualTo(0));
      expect(position.y, greaterThanOrEqualTo(0));
    }
  });
}
