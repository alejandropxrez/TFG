import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

class LinkedListValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) {
    final state = session.currentState;

    if (state.nodes.isEmpty) return false;
    if (state.nodes.length == 1) return state.edges.isEmpty;

    final outgoingCount = <String, int>{
      for (final nodeId in state.nodes.keys) nodeId: 0,
    };

    final incomingCount = <String, int>{
      for (final nodeId in state.nodes.keys) nodeId: 0,
    };

    final nextByNode = <String, String>{};

    for (final edge in state.edges) {
      if (!state.nodes.containsKey(edge.source) ||
          !state.nodes.containsKey(edge.target)) {
        return false;
      }

      outgoingCount[edge.source] = outgoingCount[edge.source]! + 1;
      incomingCount[edge.target] = incomingCount[edge.target]! + 1;

      if (outgoingCount[edge.source]! > 1) return false;
      if (incomingCount[edge.target]! > 1) return false;

      nextByNode[edge.source] = edge.target;
    }

    final heads = state.nodes.keys
        .where((nodeId) => incomingCount[nodeId] == 0)
        .toList(growable: false);

    if (heads.length != 1) return false;

    final visited = <String>{};
    var current = heads.single;

    while (true) {
      if (!visited.add(current)) {
        return false;
      }

      final next = nextByNode[current];

      if (next == null) {
        break;
      }

      current = next;
    }

    return visited.length == state.nodes.length;
  }
}
