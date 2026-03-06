import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that verifies whether the node arrangement
/// satisfies the rules of a **Binary Search Tree (BST)**.
///
/// BST properties:
/// - All values in the left subtree are **less than** the parent node.
/// - All values in the right subtree are **greater than** the parent node.
/// - Both subtrees must also satisfy the BST property.
///
/// Example:
///
///         8
///        / \
///       3   10
///      / \    \
///     1   6    14
///
/// Array representation:
/// [8, 3, 10, 1, 6, null, 14]
///
/// Index mapping:
///
///           0
///         /   \
///        1     2
///       / \   / \
///      3   4 5   6
///
/// For any node at index `i`:
/// left child  = 2*i + 1
/// right child = 2*i + 2
///
class BstValidationStrategy implements ValidationStrategy {
  /// Validates whether the challenge is solved by checking
  /// that the node structure follows **BST rules**.
  ///
  /// Returns:
  /// - true  → if the structure is a valid BST
  /// - false → if any node violates the BST constraints
  @override
  bool isSolved(ChallengeSession session) {
    final nodes = session.nodes;

    /// Recursive function that validates each node using
    /// a range constraint (`min`, `max`).
    ///
    /// - `min` → smallest allowed value
    /// - `max` → largest allowed value
    ///
    /// Each node must satisfy:
    ///
    /// min < value < max
    bool isValid(int index, int? min, int? max) {
      /// If the index is outside the array,
      /// the node does not exist and is considered valid.
      if (index >= nodes.length) return true;

      final value = nodes[index].value;

      /// Check whether the current node violates
      /// the allowed range.
      if ((min != null && value <= min) || (max != null && value >= max)) {
        return false;
      }

      /// Recursively validate:
      /// - left subtree with updated max bound
      /// - right subtree with updated min bound
      return isValid(2 * index + 1, min, value) &&
          isValid(2 * index + 2, value, max);
    }

    /// Start validation from the root node.
    /// The root has no bounds initially.
    return isValid(0, null, null);
  }
}
