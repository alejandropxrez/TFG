import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that verifies whether a graph is connected.
///
/// A graph is connected when every node can be reached from any other node
/// through a sequence of edges.
///
/// This strategy interprets every edge as **undirected**. Therefore, an edge
/// between `A` and `B` allows traversal in both directions.
///
/// Examples:
///
/// Connected graph:
///
///     A ----- B
///     |       |
///     C ----- D
///
/// Disconnected graph:
///
///     A ----- B      C ----- D
///
/// Strategy:
/// - Reject an empty graph.
/// - Accept a graph containing a single node.
/// - Build an undirected adjacency map.
/// - Reject edges that reference unknown nodes.
/// - Traverse the graph using depth-first search.
/// - Verify that every node was visited.
class ConnectedGraphValidationStrategy implements ValidationStrategy {
  /// Validates whether the challenge structure forms a connected graph.
  ///
  /// Returns `true` when every node is reachable from the selected starting
  /// node. Returns `false` for empty graphs, disconnected graphs, or edges
  /// that reference nodes outside the structure.
  @override
  bool isSolved(ChallengeSession session) {
    final state = session.structureRuntimeState.structure;

    // An empty graph is not considered connected for challenge validation.
    if (state.nodes.isEmpty) return false;

    // A graph with one node is connected without requiring any edges.
    if (state.nodes.length == 1) return true;

    final adjacency = <String, Set<String>>{
      for (final nodeId in state.nodes.keys) nodeId: <String>{},
    };

    // Build an undirected adjacency map and reject invalid edge references.
    for (final edge in state.edges) {
      if (!state.nodes.containsKey(edge.source) ||
          !state.nodes.containsKey(edge.target)) {
        return false;
      }

      adjacency[edge.source]!.add(edge.target);
      adjacency[edge.target]!.add(edge.source);
    }

    final startNodeId = state.nodes.keys.first;
    final visited = <String>{};
    final stack = <String>[startNodeId];

    // Iterative depth-first search avoids recursive stack growth.
    while (stack.isNotEmpty) {
      final currentNodeId = stack.removeLast();

      if (!visited.add(currentNodeId)) continue;

      for (final neighborId in adjacency[currentNodeId]!) {
        if (!visited.contains(neighborId)) {
          stack.add(neighborId);
        }
      }
    }

    // The graph is connected only when every node was reached.
    return visited.length == state.nodes.length;
  }
}
