import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that checks if the current node arrangement
/// satisfies the rules of a **Max Heap**.
///
/// A Max Heap is a binary tree where:
/// - Every parent node is **greater than or equal to its children**
/// - The tree is **complete**
///
/// Example of a valid Max Heap:
///
///        50
///       /  \
///     30    40
///    /  \
///  10   20
///
/// Array representation:
/// [50, 30, 40, 10, 20]
///
/// Index mapping:
///          0
///        /   \
///       1     2
///      / \
///     3   4
///
/// For any node at index i:
/// left child  = 2*i + 1
/// right child = 2*i + 2
///
class MaxHeapValidationStrategy implements ValidationStrategy {
  /// Determines whether the challenge is solved by validating
  /// that the nodes follow the **Max Heap property**.
  ///
  /// Returns:
  /// - true  → if the structure is a valid Max Heap
  /// - false → if any child node is greater than its parent
  @override
  bool isSolved(ChallengeSession session) {
    final nodes = session.nodes;

    for (int i = 0; i < nodes.length; i++) {
      /// Calculate children indexes based on heap rules
      ///
      ///        parent (i)
      ///        /      \
      /// left(2i+1)  right(2i+2)
      ///
      final left = 2 * i + 1;
      final right = 2 * i + 2;

      /// Check the left child
      ///
      /// Conditions:
      /// 1. Left child exists inside the array
      /// 2. Parent value must be >= left child value
      ///
      /// If the left child is greater than the parent,
      /// the Max Heap property is violated.
      if (left < nodes.length && nodes[i].value < nodes[left].value) {
        return false;
      }

      /// Check the right child using the same rule.
      ///
      /// Parent must be >= right child.
      if (right < nodes.length && nodes[i].value < nodes[right].value) {
        return false;
      }
    }

    /// If all nodes satisfy the Max Heap property,
    /// the structure is valid.
    return true;
  }
}
