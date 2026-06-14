import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/components/inventory_item_component.dart';
import 'package:algoquest/presentation/game/components/slot_component.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';
import 'package:flame/components.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'components/edge_component.dart';
import 'components/node_component.dart';
import 'strategies/layout/layout_strategy_factory.dart';

class VisualScene {
  final List<Component> components;
  final Map<String, Vector2> slotPositions;

  const VisualScene({required this.components, required this.slotPositions});
}

class VisualSceneBuilder {
  final LayoutStrategyFactory _layoutStrategyFactory;

  const VisualSceneBuilder({
    LayoutStrategyFactory layoutStrategyFactory = const LayoutStrategyFactory(),
  }) : _layoutStrategyFactory = layoutStrategyFactory;

  VisualScene build({
    required StructureChallengeContent structureContent,
    required StructureState state,
    required Vector2 canvasSize,
    required InteractionStrategy interactionStrategy,
    required void Function(GameAction action) onActionRequested,
    required void Function() onInteractionChanged,
    void Function(int value, Vector2 position)? onInventoryDragStart,
    void Function(int value, Vector2 position)? onInventoryDragUpdate,
    void Function(int value, Vector2 position)? onInventoryDragEnd,
  }) {
    final components = <Component>[];

    void handleNodeTap(String nodeId) {
      final action = interactionStrategy.handleNodeTap(nodeId);

      if (action != null) {
        onActionRequested(action);
      }

      onInteractionChanged();
    }

    void handleEdgeTap(String sourceNodeId, String targetNodeId) {
      final action = interactionStrategy.handleEdgeTap(
        sourceNodeId,
        targetNodeId,
      );

      if (action != null) {
        onActionRequested(action);
      }

      onInteractionChanged();
    }

    void handleInventoryTap(int selectedValue) {
      final action = interactionStrategy.handleInventoryTap(selectedValue);

      if (action != null) {
        onActionRequested(action);
      }

      onInteractionChanged();
    }

    final layoutStrategy = _layoutStrategyFactory.create(
      structureContent.engineConfig.layoutStrategy,
    );

    final positions = layoutStrategy.calculatePositions(
      state: state,
      canvasSize: canvasSize,
    );

    final slotPositions = <String, Vector2>{};

    for (final slot in state.slots.values) {
      slotPositions[slot.id] = _slotPosition(
        slotIndex: slot.index,
        slotCount: state.slots.length,
        canvasSize: canvasSize,
      );
    }

    final slotNodeIds = state.slots.values
        .map((slot) => slot.filledNodeId)
        .whereType<String>()
        .toSet();

    final remainingInventoryValues = List<int>.from(state.inventory);
    final inventoryNodeIds = <String>{};

    for (final node in state.nodes.values) {
      final value = node.value;
      if (value == null) continue;

      final inventoryIndex = remainingInventoryValues.indexOf(value);
      if (inventoryIndex == -1) continue;

      inventoryNodeIds.add(node.id);
      remainingInventoryValues.removeAt(inventoryIndex);
    }

    final slotNodePositions = <String, Vector2>{};

    for (final slot in state.slots.values) {
      final filledNodeId = slot.filledNodeId;
      if (filledNodeId == null) continue;

      final slotPosition = slotPositions[slot.id];
      if (slotPosition == null) continue;

      slotNodePositions[filledNodeId] = slotPosition;
    }

    final edgesToRender = state.edges;

    for (final edge in edgesToRender) {
      final start = slotNodePositions[edge.source] ?? positions[edge.source];
      final end = slotNodePositions[edge.target] ?? positions[edge.target];

      if (start != null && end != null) {
        final shouldCurveEdge = _shouldCurveEdge(
          sourceNodeId: edge.source,
          targetNodeId: edge.target,
          positions: positions,
        );

        components.add(
          EdgeComponent(
            start: start,
            end: end,
            sourceNodeId: edge.source,
            targetNodeId: edge.target,
            isCurved: shouldCurveEdge,
            onTapEdge: handleEdgeTap,
          ),
        );
      }
    }

    for (final entry in state.nodes.entries) {
      if (slotNodeIds.contains(entry.key)) continue;
      if (inventoryNodeIds.contains(entry.key)) continue;

      final position = positions[entry.key];
      if (position == null) continue;

      components.add(
        NodeComponent(
          nodeId: entry.key,
          value: entry.value.value,
          position: position,
          isSelected: interactionStrategy.selectedNodeIds.contains(entry.key),
          onTapNode: handleNodeTap,
        ),
      );
    }

    for (final slot in state.slots.values) {
      final slotPosition = slotPositions[slot.id];
      if (slotPosition == null) continue;

      final filledNodeId = slot.filledNodeId;

      if (filledNodeId != null) {
        final filledNode = state.nodes[filledNodeId];

        if (filledNode != null) {
          components.add(
            NodeComponent(
              nodeId: filledNode.id,
              value: filledNode.value,
              position: slotPosition,
              isSelected: interactionStrategy.selectedNodeIds.contains(
                filledNode.id,
              ),
              onTapNode: handleNodeTap,
            ),
          );
        }

        continue;
      }

      components.add(
        SlotComponent(
          slotId: slot.id,
          position: slotPosition,
          isSelected: interactionStrategy.selectedNodeIds.contains(slot.id),
          onTapSlot: handleNodeTap,
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
          onTapInventoryItem: handleInventoryTap,
          onDragStartItem: onInventoryDragStart,
          onDragUpdateItem: onInventoryDragUpdate,
          onDragEndItem: onInventoryDragEnd,
        ),
      );
    }

    return VisualScene(components: components, slotPositions: slotPositions);
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

  bool _shouldCurveEdge({
    required String sourceNodeId,
    required String targetNodeId,
    required Map<String, Vector2> positions,
  }) {
    final start = positions[sourceNodeId];
    final end = positions[targetNodeId];

    if (start == null || end == null) {
      return false;
    }

    for (final entry in positions.entries) {
      final nodeId = entry.key;

      if (nodeId == sourceNodeId || nodeId == targetNodeId) {
        continue;
      }

      final distance = _distanceFromPointToSegment(
        point: entry.value,
        start: start,
        end: end,
      );

      if (distance < 24) {
        return true;
      }
    }

    return false;
  }

  double _distanceFromPointToSegment({
    required Vector2 point,
    required Vector2 start,
    required Vector2 end,
  }) {
    final segment = end - start;
    final lengthSquared = segment.length2;

    if (lengthSquared == 0) {
      return point.distanceTo(start);
    }

    final pointVector = point - start;
    final t = (pointVector.dot(segment) / lengthSquared).clamp(0.0, 1.0);
    final projection = start + segment * t;

    return point.distanceTo(projection);
  }
}
