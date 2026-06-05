import 'package:algoquest/presentation/game/strategies/connection/connection_strategy_factory.dart';
import 'package:flame/components.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'components/edge_component.dart';
import 'components/node_component.dart';
import 'strategies/layout/layout_strategy_factory.dart';

class VisualScene {
  final List<Component> components;

  const VisualScene(this.components);
}

class VisualSceneBuilder {
  final LayoutStrategyFactory _layoutStrategyFactory;
  final ConnectionStrategyFactory _connectionStrategyFactory;

  const VisualSceneBuilder({
    LayoutStrategyFactory layoutStrategyFactory = const LayoutStrategyFactory(),
    ConnectionStrategyFactory connectionStrategyFactory =
        const ConnectionStrategyFactory(),
  }) : _layoutStrategyFactory = layoutStrategyFactory,
       _connectionStrategyFactory = connectionStrategyFactory;

  VisualScene build({
    required ChallengeSpec spec,
    required StructureState state,
    required Vector2 canvasSize,
    String? selectedNodeId,
    void Function(String nodeId)? onTapNode,
  }) {
    final layoutStrategy = _layoutStrategyFactory.create(
      spec.engineConfig.layoutStrategy,
    );

    final positions = layoutStrategy.calculatePositions(
      state: state,
      canvasSize: canvasSize,
    );

    final components = <Component>[];

    final connectionStrategy = _connectionStrategyFactory.create(
      spec.engineConfig.connectionType,
    );

    final edgesToRender = connectionStrategy.buildConnections(state);

    for (final edge in edgesToRender) {
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
}
