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
    if (slot.filledNodeId != null) return false;
    if (!state.inventory.contains(value)) return false;
    return true;
  }

  @override
  StructureState transform(StructureState currentState) {
    if (!isApplicableTo(currentState)) return currentState;

    final slot = currentState.slots[slotId]!;

    final newNodeId = slotId;

    final updatedNodes = Map<String, NodeState>.from(currentState.nodes);
    updatedNodes[newNodeId] = NodeState(id: newNodeId, value: value);

    final updatedSlots = Map<String, SlotState>.from(currentState.slots);
    updatedSlots[slotId] = slot.copyWith(filledNodeId: newNodeId);

    final updatedInventory = List<int>.from(currentState.inventory);
    updatedInventory.remove(value);

    return currentState.copyWith(
      nodes: updatedNodes,
      slots: updatedSlots,
      inventory: updatedInventory,
    );
  }
}
