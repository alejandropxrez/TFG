import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that checks whether the current node
/// arrangement satisfies the rules of a **Max Heap**.
///
/// A Max Heap is a tree where:
/// - Every parent node is **greater than or equal to its children**
/// - The structure is assumed to be a valid tree (handled elsewhere)
///
/// Example:
///
///        50
///       /  \
///     30    40
///    /  \
///  10   20
///
/// Edges:
/// n1 → n2, n1 → n3, n2 → n4, n2 → n5
///
/// Validation rule:
/// For every edge (parent → child):
///
/// parent.value >= child.value
///
class MaxHeapValidationStrategy implements ValidationStrategy {
  /// Validates whether the challenge is solved by verifying
  /// that all parent-child relationships satisfy the **Max Heap property**.
  ///
  /// Returns:
  /// - true  → if all parent nodes are >= their children
  /// - false → if any parent node is smaller than a child
  @override
  bool isSolved(ChallengeSession session) {
    final state = session.currentState;

    for (final edge in state.edges) {
      final parent = state.nodes[edge.source];
      final child = state.nodes[edge.target];

      /// Invalid structure → fail fast
      if (parent == null || child == null) return false;

      final parentValue = parent.value;
      final childValue = child.value;

      /// Null values are considered invalid
      if (parentValue == null || childValue == null) return false;

      /// Max Heap rule violation
      if (parentValue < childValue) {
        return false;
      }
    }

    return true;
  }
}
