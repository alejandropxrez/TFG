import 'structure_state.dart';

sealed class GameAction {
  const GameAction();

  /// Returns whether the action can be applied to the current structure state.
  bool isApplicableTo(StructureState state);

  /// Returns a new transformed structure state.
  ///
  /// Assumes the action is applicable. If not applicable, it may simply return
  /// the original state.
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

class SetNodeValueAction extends GameAction {
  final String nodeId;
  final int value;

  const SetNodeValueAction({required this.nodeId, required this.value});

  @override
  bool isApplicableTo(StructureState state) {
    return state.nodes.containsKey(nodeId);
  }

  @override
  StructureState transform(StructureState currentState) {
    if (!isApplicableTo(currentState)) return currentState;

    final node = currentState.nodes[nodeId]!;

    final updatedNodes = Map<String, NodeState>.from(currentState.nodes);
    updatedNodes[nodeId] = node.copyWith(value: value);

    return currentState.copyWith(nodes: updatedNodes);
  }
}
