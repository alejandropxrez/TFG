import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/components/inventory_item_component.dart';
import 'package:algoquest/presentation/game/components/slot_component.dart';
import 'package:algoquest/presentation/game/strategies/connection/connection_strategy_factory.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';
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
    required InteractionStrategy interactionStrategy,
    required void Function(GameAction action) onActionRequested,
    required void Function() onInteractionChanged,
  }) {
    final components = <Component>[];

    final layoutStrategy = _layoutStrategyFactory.create(
      spec.engineConfig.layoutStrategy,
    );

    final positions = layoutStrategy.calculatePositions(
      state: state,
      canvasSize: canvasSize,
    );

    final slotNodeIds = state.slots.values
        .map((slot) => slot.filledNodeId)
        .whereType<String>()
        .toSet();

    final slotNodePositions = <String, Vector2>{};

    for (final slot in state.slots.values) {
      final filledNodeId = slot.filledNodeId;
      if (filledNodeId == null) continue;

      slotNodePositions[filledNodeId] = _slotPosition(
        slotIndex: slot.index,
        slotCount: state.slots.length,
        canvasSize: canvasSize,
      );
    }

    final connectionStrategy = _connectionStrategyFactory.create(
      spec.engineConfig.connectionType,
    );

    final edgesToRender = connectionStrategy.buildConnections(state);

    for (final edge in edgesToRender) {
      final start = slotNodePositions[edge.source] ?? positions[edge.source];
      final end = slotNodePositions[edge.target] ?? positions[edge.target];

      if (start != null && end != null) {
        components.add(EdgeComponent(start: start, end: end));
      }
    }

    for (final entry in state.nodes.entries) {
      if (slotNodeIds.contains(entry.key)) continue;

      final position = positions[entry.key];
      if (position == null) continue;

      components.add(
        NodeComponent(
          nodeId: entry.key,
          value: entry.value.value,
          position: position,
          isSelected: interactionStrategy.selectedNodeId == entry.key,
          onTapNode: (nodeId) {
            final action = interactionStrategy.handleNodeTap(nodeId);

            if (action != null) {
              onActionRequested(action);
            }

            onInteractionChanged();
          },
        ),
      );
    }

    for (final slot in state.slots.values) {
      final slotPosition = _slotPosition(
        slotIndex: slot.index,
        slotCount: state.slots.length,
        canvasSize: canvasSize,
      );

      final filledNodeId = slot.filledNodeId;

      if (filledNodeId != null) {
        final filledNode = state.nodes[filledNodeId];

        if (filledNode != null) {
          components.add(
            NodeComponent(
              nodeId: filledNode.id,
              value: filledNode.value,
              position: slotPosition,
              isSelected: interactionStrategy.selectedNodeId == filledNode.id,
              onTapNode: (nodeId) {
                final action = interactionStrategy.handleNodeTap(nodeId);

                if (action != null) {
                  onActionRequested(action);
                }

                onInteractionChanged();
              },
            ),
          );
        }

        continue;
      }

      components.add(
        SlotComponent(
          slotId: slot.id,
          position: slotPosition,
          isSelected: interactionStrategy.selectedNodeId == slot.id,
          onTapSlot: (slotId) {
            final action = interactionStrategy.handleNodeTap(slotId);

            if (action != null) {
              onActionRequested(action);
            }

            onInteractionChanged();
          },
        ),
      );
    }

    for (var i = 0; i < state.inventory.length; i++) {
      final value = state.inventory[i];

      components.add(
        InventoryItemComponent(
          value: value,
          position: _inventoryPosition(
            index: i,
            total: state.inventory.length,
            canvasSize: canvasSize,
          ),
          isSelected: interactionStrategy.selectedInventoryValue == value,
          onTapInventoryItem: (selectedValue) {
            final action = interactionStrategy.handleInventoryTap(
              selectedValue,
            );

            if (action != null) {
              onActionRequested(action);
            }

            onInteractionChanged();
          },
        ),
      );
    }

    return VisualScene(components);
  }

  Vector2 _slotPosition({
    required int? slotIndex,
    required int slotCount,
    required Vector2 canvasSize,
  }) {
    final index = slotIndex ?? 0;
    const spacing = 88.0;

    final startX = canvasSize.x / 2.0 - ((slotCount - 1) * spacing) / 2.0;

    return Vector2(startX + index * spacing, canvasSize.y * 0.35);
  }

  Vector2 _inventoryPosition({
    required int index,
    required int total,
    required Vector2 canvasSize,
  }) {
    const spacing = 76.0;

    final startX = canvasSize.x / 2.0 - ((total - 1) * spacing) / 2.0;

    return Vector2(startX + index * spacing, canvasSize.y - 96.0);
  }
}
