import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that checks whether the current node
/// arrangement satisfies the rules of a **Min Heap**.
///
/// A Min Heap is a binary tree where:
/// - Every parent node is **less than or equal to its children**
/// - The tree is **complete**
///
/// Example of a valid Min Heap:
///
///        10
///       /  \
///     20    30
///    /  \
///  40   50
///
/// Array representation:
/// [10, 20, 30, 40, 50]
///
/// Index mapping:
///
///          0
///        /   \
///       1     2
///      / \
///     3   4
///
/// For a node at index `i`:
/// left child  = 2*i + 1
/// right child = 2*i + 2
///
class MinHeapValidationStrategy implements ValidationStrategy {
  /// Validates whether the challenge is solved by verifying
  /// that the nodes follow the **Min Heap property**.
  ///
  /// Returns:
  /// - true  → if the structure is a valid Min Heap
  /// - false → if any parent node is greater than its children
  @override
  bool isSolved(ChallengeSession session) {
    final nodes = session.nodes;

    for (int i = 0; i < nodes.length; i++) {
      /// Compute the indexes of the children using heap rules.
      ///
      ///        parent (i)
      ///        /      \
      /// left(2i+1)  right(2i+2)
      final left = 2 * i + 1;
      final right = 2 * i + 2;

      /// Validate the left child.
      ///
      /// Conditions:
      /// 1. The left child index must exist in the array
      /// 2. Parent value must be <= left child value
      ///
      /// If the parent is greater than the left child,
      /// the Min Heap property is violated.
      if (left < nodes.length && nodes[i].value > nodes[left].value) {
        return false;
      }

      /// Validate the right child using the same rule.
      ///
      /// Parent must be <= right child.
      if (right < nodes.length && nodes[i].value > nodes[right].value) {
        return false;
      }
    }

    /// If no violations were found,
    /// the structure satisfies the Min Heap property.
    return true;
  }
}
