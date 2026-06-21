import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that verifies whether the structure forms a valid
/// singly linked list.
///
/// A valid linked list must satisfy these properties:
///
/// - the structure contains at least one node;
/// - exactly one node has no incoming edge and acts as the head;
/// - every node has at most one incoming edge;
/// - every node has at most one outgoing edge;
/// - traversal from the head does not enter a cycle;
/// - every node is reachable from the head.
///
/// A single node with no edges is considered a valid linked list.
///
/// Example:
///
/// ```text
/// A → B → C → D
/// ```
///
/// Invalid examples:
///
/// ```text
/// A → B → C
///     ↑   |
///     └───┘
/// ```
///
/// ```text
/// A → B    C → D
/// ```
///
/// Strategy:
/// - Count incoming and outgoing edges for every node.
/// - Reject edges that reference unknown nodes.
/// - Reject nodes with multiple predecessors or successors.
/// - Find the unique head node.
/// - Traverse the list from the head.
/// - Detect cycles and disconnected nodes.
class LinkedListValidationStrategy implements ValidationStrategy {
  /// Validates whether the challenge structure forms a single linked list.
  ///
  /// Returns `false` for empty structures, malformed edges, multiple heads,
  /// branching nodes, cycles, or disconnected nodes.
  @override
  bool isSolved(ChallengeSession session) {
    final state = session.structureRuntimeState.structure;

    // An empty structure is not considered a valid challenge solution.
    if (state.nodes.isEmpty) return false;

    // A single isolated node forms a valid linked list.
    if (state.nodes.length == 1) return state.edges.isEmpty;

    final outgoingCount = <String, int>{
      for (final nodeId in state.nodes.keys) nodeId: 0,
    };

    final incomingCount = <String, int>{
      for (final nodeId in state.nodes.keys) nodeId: 0,
    };

    final nextByNode = <String, String>{};

    // Build the successor mapping and enforce one predecessor and one
    // successor at most for every node.
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

    // A valid linked list must have exactly one head.
    if (heads.length != 1) return false;

    final visited = <String>{};
    var currentNodeId = heads.single;

    // Traverse successors from the head and reject repeated nodes.
    while (true) {
      if (!visited.add(currentNodeId)) {
        return false;
      }

      final nextNodeId = nextByNode[currentNodeId];

      if (nextNodeId == null) {
        break;
      }

      currentNodeId = nextNodeId;
    }

    // Every node must belong to the same chain.
    return visited.length == state.nodes.length;
  }
}
