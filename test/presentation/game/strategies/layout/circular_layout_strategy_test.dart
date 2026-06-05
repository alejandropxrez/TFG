import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/presentation/game/strategies/layout/circular_layout_strategy.dart';
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
    final strategy = const CircularLayoutStrategy();

    final positions = strategy.calculatePositions(
      state: buildState(nodeIds: const []),
      canvasSize: Vector2(400, 300),
    );

    expect(positions, isEmpty);
  });

  test('places a single node at the center of the canvas', () {
    final strategy = const CircularLayoutStrategy();

    final positions = strategy.calculatePositions(
      state: buildState(nodeIds: const ['n1']),
      canvasSize: Vector2(400, 300),
    );

    expect(positions.length, 1);
    expect(positions['n1']!.x, 200);
    expect(positions['n1']!.y, 150);
  });

  test('returns one position for each node', () {
    final strategy = const CircularLayoutStrategy();

    final positions = strategy.calculatePositions(
      state: buildState(nodeIds: const ['n1', 'n2', 'n3', 'n4']),
      canvasSize: Vector2(400, 400),
    );

    expect(positions.keys, containsAll(['n1', 'n2', 'n3', 'n4']));
    expect(positions.length, 4);
  });

  test('keeps node positions inside the canvas', () {
    final strategy = const CircularLayoutStrategy();

    final positions = strategy.calculatePositions(
      state: buildState(nodeIds: const ['n1', 'n2', 'n3', 'n4']),
      canvasSize: Vector2(400, 400),
    );

    for (final position in positions.values) {
      expect(position.x, greaterThanOrEqualTo(0));
      expect(position.x, lessThanOrEqualTo(400));
      expect(position.y, greaterThanOrEqualTo(0));
      expect(position.y, lessThanOrEqualTo(400));
    }
  });
}
