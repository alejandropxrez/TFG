import 'structure_state.dart';

/// Base type for every action that can modify a [StructureState].
///
/// Each action follows two steps:
///
/// 1. [isApplicableTo] checks whether the action is valid for a given state.
/// 2. [transform] produces the resulting immutable state.
///
/// Implementations must return the original state unchanged when the action is
/// not applicable.
sealed class GameAction {
  const GameAction();

  /// Whether this action can be executed on [state].
  bool isApplicableTo(StructureState state);

  /// Applies this action to [currentState].
  ///
  /// Returns a new [StructureState] when the action is valid, or the original
  /// state when it cannot be applied.
  StructureState transform(StructureState currentState);
}

/// Swaps the values stored by two existing nodes.
///
/// The node identifiers and graph topology remain unchanged; only the node
/// values are exchanged.
class SwapNodesAction extends GameAction {
  /// Identifier of the first node involved in the swap.
  final String firstNodeId;

  /// Identifier of the second node involved in the swap.
  final String secondNodeId;

  const SwapNodesAction({
    required this.firstNodeId,
    required this.secondNodeId,
  });

  /// The swap is valid only when both nodes exist and are different.
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

/// Assigns an inventory value to a structure slot.
///
/// The action removes the selected value from the inventory and associates an
/// available node containing that value with the target slot.
///
/// When replacing an existing slot value, the previous value is returned to
/// the inventory.
class SetValueAction extends GameAction {
  /// Identifier of the slot that receives the value.
  final String slotId;

  /// Value selected from the inventory.
  final int value;

  const SetValueAction({required this.slotId, required this.value});

  /// The action is valid when:
  ///
  /// - the target slot exists;
  /// - the value exists in the inventory;
  /// - an unused node containing that value is available.
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

  /// Finds an unused node whose value matches [value].
  ///
  /// Nodes already referenced by another slot are excluded.
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

/// Creates an undirected connection between two nodes.
///
/// Although an [EdgeState] stores a source and a target, link duplication is
/// checked in both directions, so `A → B` and `B → A` are treated as the same
/// connection.
class LinkAction extends GameAction {
  /// Identifier of the source node.
  final String sourceNodeId;

  /// Identifier of the target node.
  final String targetNodeId;

  const LinkAction({required this.sourceNodeId, required this.targetNodeId});

  /// The link is valid when both nodes exist, are different, and no equivalent
  /// edge already exists in either direction.
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

/// Removes the undirected connection between two nodes.
///
/// Both possible source-target orientations are considered equivalent and are
/// removed when present.
class RemoveLinkAction extends GameAction {
  /// Identifier of one endpoint of the edge.
  final String sourceNodeId;

  /// Identifier of the other endpoint of the edge.
  final String targetNodeId;

  const RemoveLinkAction({
    required this.sourceNodeId,
    required this.targetNodeId,
  });

  /// Whether an equivalent edge exists in either direction.
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

/// Removes the value currently assigned to a slot.
///
/// The slot becomes empty and its associated node value is returned to the
/// inventory so that it can be placed again.
class ClearSlotAction extends GameAction {
  /// Identifier of the slot to clear.
  final String slotId;

  const ClearSlotAction({required this.slotId});

  /// The action is valid when the slot exists, is filled, and references a node
  /// with a value.
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
