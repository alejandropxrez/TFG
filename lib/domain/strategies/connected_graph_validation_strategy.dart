import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

class ConnectedGraphValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) {
    final state = session.currentState;

    if (state.nodes.isEmpty) return false;
    if (state.nodes.length == 1) return true;

    final adjacency = <String, Set<String>>{
      for (final nodeId in state.nodes.keys) nodeId: <String>{},
    };

    for (final edge in state.edges) {
      if (!state.nodes.containsKey(edge.source) ||
          !state.nodes.containsKey(edge.target)) {
        return false;
      }

      adjacency[edge.source]!.add(edge.target);
      adjacency[edge.target]!.add(edge.source);
    }

    final start = state.nodes.keys.first;
    final visited = <String>{};
    final stack = <String>[start];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();

      if (!visited.add(current)) continue;

      for (final neighbor in adjacency[current]!) {
        if (!visited.contains(neighbor)) {
          stack.add(neighbor);
        }
      }
    }

    return visited.length == state.nodes.length;
  }
}
