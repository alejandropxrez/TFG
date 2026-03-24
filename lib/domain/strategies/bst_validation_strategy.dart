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
/// - Traverse using DFS
/// - Enforce value ranges (min, max)
///
class BstValidationStrategy implements ValidationStrategy {
  /// Validates whether the challenge is solved by checking
  /// that the structure follows **BST rules**.
  ///
  /// Returns:
  /// - true  → if the structure is a valid BST
  /// - false → if any node violates BST constraints
  @override
  bool isSolved(ChallengeSession session) {
    final state = session.currentState;

    if (state.nodes.isEmpty) return true;

    final rootId = _findRootId(state);
    if (rootId == null) return false;

    final childrenMap = _buildChildrenMap(state);

    return _validateNode(
      nodeId: rootId,
      state: state,
      childrenMap: childrenMap,
      min: null,
      max: null,
    );
  }

  /// Finds the root node (node that is never a child).
  String? _findRootId(StructureState state) {
    final allNodes = state.nodes.keys.toSet();
    final childNodes = state.edges.map((e) => e.target).toSet();

    final rootCandidates = allNodes.difference(childNodes);

    if (rootCandidates.length != 1) return null;

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

  /// Recursively validates each node using value bounds.
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
  }) {
    final node = state.nodes[nodeId];
    if (node == null || node.value == null) return false;

    final value = node.value!;

    /// Range validation
    if (min != null && value <= min) return false;
    if (max != null && value >= max) return false;

    final children = childrenMap[nodeId] ?? const [];

    /// BST must have at most 2 children
    if (children.length > 2) return false;

    String? left;
    String? right;

    /// Infer left/right based on value
    for (final childId in children) {
      final child = state.nodes[childId];
      if (child == null || child.value == null) return false;

      if (child.value! < value) {
        if (left != null) return false;
        left = childId;
      } else if (child.value! > value) {
        if (right != null) return false;
        right = childId;
      } else {
        return false;
      }
    }

    /// Validate subtrees
    final leftValid = left == null
        ? true
        : _validateNode(
            nodeId: left,
            state: state,
            childrenMap: childrenMap,
            min: min,
            max: value,
          );

    if (!leftValid) return false;

    final rightValid = right == null
        ? true
        : _validateNode(
            nodeId: right,
            state: state,
            childrenMap: childrenMap,
            min: value,
            max: max,
          );

    return rightValid;
  }
}
