import 'structure_state.dart';

sealed class GameAction {
  const GameAction();

  bool isApplicableTo(StructureState state);

  StructureState transform(StructureState currentState);
}

class SwapNodesAction extends GameAction {
  final String firstNodeId;
  final String secondNodeId;

  const SwapNodesAction({
    required this.firstNodeId,
    required this.secondNodeId,
  });

  @override
  bool isApplicableTo(StructureState state) {
    return state.nodes.containsKey(firstNodeId) &&
        state.nodes.containsKey(secondNodeId) &&
        firstNodeId != secondNodeId;
  }

  @override
  StructureState transform(StructureState currentState) {
    if (!isApplicableTo(currentState)) return currentState;

    final firstNode = currentState.nodes[firstNodeId]!;
    final secondNode = currentState.nodes[secondNodeId]!;

    final updatedNodes = Map<String, NodeState>.from(currentState.nodes);
    updatedNodes[firstNodeId] = firstNode.copyWith(value: secondNode.value);
    updatedNodes[secondNodeId] = secondNode.copyWith(value: firstNode.value);

    return currentState.copyWith(nodes: updatedNodes);
  }
}

class SetValueAction extends GameAction {
  final String slotId;
  final int value;

  const SetValueAction({required this.slotId, required this.value});

  @override
  bool isApplicableTo(StructureState state) {
    final slot = state.slots[slotId];

    if (slot == null) return false;
    if (!state.inventory.contains(value)) return false;

    return _findAvailableNodeForValue(state) != null;
  }

  @override
  StructureState transform(StructureState currentState) {
    if (!isApplicableTo(currentState)) return currentState;

    final slot = currentState.slots[slotId]!;
    final nextNode = _findAvailableNodeForValue(currentState);

    if (nextNode == null) return currentState;

    final previousFilledNodeId = slot.filledNodeId;
    final previousValue = previousFilledNodeId == null
        ? null
        : currentState.nodes[previousFilledNodeId]?.value;

    final updatedSlots = Map<String, SlotState>.from(currentState.slots)
      ..[slotId] = slot.copyWith(filledNodeId: nextNode.id);

    final updatedInventory = List<int>.from(currentState.inventory)
      ..remove(value);

    if (previousValue != null) {
      updatedInventory.add(previousValue);
    }

    return currentState.copyWith(
      slots: updatedSlots,
      inventory: updatedInventory,
    );
  }

  NodeState? _findAvailableNodeForValue(StructureState state) {
    final usedNodeIds = state.slots.values
        .map((slot) => slot.filledNodeId)
        .whereType<String>()
        .toSet();

    for (final node in state.nodes.values) {
      if (usedNodeIds.contains(node.id)) continue;
      if (node.value != value) continue;

      return node;
    }

    return null;
  }
}

class LinkAction extends GameAction {
  final String sourceNodeId;
  final String targetNodeId;

  const LinkAction({required this.sourceNodeId, required this.targetNodeId});

  @override
  bool isApplicableTo(StructureState state) {
    if (!state.nodes.containsKey(sourceNodeId)) return false;
    if (!state.nodes.containsKey(targetNodeId)) return false;
    if (sourceNodeId == targetNodeId) return false;

    final alreadyExists = state.edges.any(
      (edge) =>
          (edge.source == sourceNodeId && edge.target == targetNodeId) ||
          (edge.source == targetNodeId && edge.target == sourceNodeId),
    );

    return !alreadyExists;
  }

  @override
  StructureState transform(StructureState currentState) {
    if (!isApplicableTo(currentState)) return currentState;

    return currentState.copyWith(
      edges: [
        ...currentState.edges,
        EdgeState(source: sourceNodeId, target: targetNodeId),
      ],
    );
  }
}

class RemoveLinkAction extends GameAction {
  final String sourceNodeId;
  final String targetNodeId;

  const RemoveLinkAction({
    required this.sourceNodeId,
    required this.targetNodeId,
  });

  @override
  bool isApplicableTo(StructureState state) {
    return state.edges.any(
      (edge) =>
          (edge.source == sourceNodeId && edge.target == targetNodeId) ||
          (edge.source == targetNodeId && edge.target == sourceNodeId),
    );
  }

  @override
  StructureState transform(StructureState currentState) {
    if (!isApplicableTo(currentState)) return currentState;

    return currentState.copyWith(
      edges: currentState.edges
          .where(
            (edge) =>
                !((edge.source == sourceNodeId &&
                        edge.target == targetNodeId) ||
                    (edge.source == targetNodeId &&
                        edge.target == sourceNodeId)),
          )
          .toList(growable: false),
    );
  }
}

class ClearSlotAction extends GameAction {
  final String slotId;

  const ClearSlotAction({required this.slotId});

  @override
  bool isApplicableTo(StructureState state) {
    final slot = state.slots[slotId];

    if (slot == null) return false;
    if (slot.filledNodeId == null) return false;

    final filledNode = state.nodes[slot.filledNodeId];

    return filledNode?.value != null;
  }

  @override
  StructureState transform(StructureState currentState) {
    if (!isApplicableTo(currentState)) return currentState;

    final slot = currentState.slots[slotId]!;
    final filledNodeId = slot.filledNodeId!;
    final filledNode = currentState.nodes[filledNodeId]!;

    final updatedSlots = Map<String, SlotState>.from(currentState.slots)
      ..[slotId] = slot.copyWith(filledNodeId: null);

    final updatedInventory = List<int>.from(currentState.inventory)
      ..add(filledNode.value!);

    return currentState.copyWith(
      slots: updatedSlots,
      inventory: updatedInventory,
    );
  }
}
