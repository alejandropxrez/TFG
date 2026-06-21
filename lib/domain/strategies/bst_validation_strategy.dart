import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that verifies whether the node arrangement
/// satisfies the rules of a **Binary Search Tree (BST)**.
///
/// BST properties:
/// - All values in the left subtree are **less than** the parent node.
/// - All values in the right subtree are **greater than** the parent node.
/// - This property must hold recursively for every subtree.
/// - The structure must form a single valid tree:
///   - exactly one root
///   - no cycles
///   - all nodes reachable from the root
///
/// Example:
///
///         8
///        / \
///       3   10
///      / \    \
///     1   6    14
///
/// Edges:
/// n1 → n2, n1 → n3, n2 → n4, n2 → n5, n3 → n6
///
/// Strategy:
/// - Find the root (node with no parent)
/// - Build parent → children map
/// - Traverse using DFS
/// - Enforce value ranges (`min`, `max`)
/// - Detect cycles and disconnected nodes
class BstValidationStrategy implements ValidationStrategy {
  /// Validates whether the challenge is solved by checking
  /// that the structure follows **BST rules**.
  ///
  /// Returns:
  /// - true  → if the structure is a valid BST
  /// An empty structure is considered a valid BST.
  /// - false → if the structure is invalid, cyclic, disconnected,
  ///            or any node violates BST constraints
  @override
  bool isSolved(ChallengeSession session) {
    final state = session.structureRuntimeState.structure;

    if (state.nodes.isEmpty) return true;

    final rootId = _findRootId(state);
    if (rootId == null) return false;

    final childrenMap = _buildChildrenMap(state);

    final visited = <String>{};
    final recursionStack = <String>{};

    final isValid = _validateNode(
      nodeId: rootId,
      state: state,
      childrenMap: childrenMap,
      min: null,
      max: null,
      visited: visited,
      recursionStack: recursionStack,
    );

    if (!isValid) return false;

    // All nodes must belong to the same tree rooted at rootId.
    return visited.length == state.nodes.length;
  }

  /// Finds the root node (node that is never a child).
  ///
  /// A valid tree must have exactly one root.
  String? _findRootId(StructureState state) {
    final allNodeIds = state.nodes.keys.toSet();
    final childIds = state.edges.map((e) => e.target).toSet();

    final rootCandidates = allNodeIds.difference(childIds);

    if (rootCandidates.length != 1) {
      return null;
    }

    return rootCandidates.first;
  }

  /// Builds a map of parent → children.
  Map<String, List<String>> _buildChildrenMap(StructureState state) {
    final map = <String, List<String>>{};

    for (final edge in state.edges) {
      map.putIfAbsent(edge.source, () => []).add(edge.target);
    }

    return map;
  }

  /// Recursively validates each node using:
  /// - BST value bounds (`min`, `max`)
  /// - structural rules (max 2 children)
  /// - cycle detection
  ///
  /// Each node must satisfy:
  ///
  /// min < value < max
  bool _validateNode({
    required String nodeId,
    required StructureState state,
    required Map<String, List<String>> childrenMap,
    required int? min,
    required int? max,
    required Set<String> visited,
    required Set<String> recursionStack,
  }) {
    // Cycle detected
    if (recursionStack.contains(nodeId)) {
      return false;
    }

    final node = state.nodes[nodeId];
    if (node == null || node.value == null) {
      return false;
    }

    final value = node.value!;

    // Range validation
    if (min != null && value <= min) return false;
    if (max != null && value >= max) return false;

    final children = childrenMap[nodeId] ?? const [];

    // A BST node can have at most 2 children.
    if (children.length > 2) return false;

    recursionStack.add(nodeId);
    visited.add(nodeId);

    String? leftChildId;
    String? rightChildId;

    // Infer left/right child based on value relative to parent.
    for (final childId in children) {
      final child = state.nodes[childId];
      if (child == null || child.value == null) {
        recursionStack.remove(nodeId);
        return false;
      }

      if (child.value! < value) {
        if (leftChildId != null) {
          recursionStack.remove(nodeId);
          return false;
        }
        leftChildId = childId;
      } else if (child.value! > value) {
        if (rightChildId != null) {
          recursionStack.remove(nodeId);
          return false;
        }
        rightChildId = childId;
      } else {
        // Equal values are not allowed in this BST definition.
        recursionStack.remove(nodeId);
        return false;
      }
    }

    final leftValid = leftChildId == null
        ? true
        : _validateNode(
            nodeId: leftChildId,
            state: state,
            childrenMap: childrenMap,
            min: min,
            max: value,
            visited: visited,
            recursionStack: recursionStack,
          );

    if (!leftValid) {
      recursionStack.remove(nodeId);
      return false;
    }

    final rightValid = rightChildId == null
        ? true
        : _validateNode(
            nodeId: rightChildId,
            state: state,
            childrenMap: childrenMap,
            min: value,
            max: max,
            visited: visited,
            recursionStack: recursionStack,
          );

    recursionStack.remove(nodeId);
    return rightValid;
  }
}
