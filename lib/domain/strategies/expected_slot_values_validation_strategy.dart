import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that checks whether specific slots contain the expected
/// values.
///
/// The expected solution is represented by [expectedValuesBySlotId], where:
///
/// - each key is a slot identifier;
/// - each value is the value that must be assigned to that slot.
///
/// A slot is considered correct only when it:
///
/// - exists in the current structure;
/// - references a filled node;
/// - references an existing node;
/// - contains the expected value.
///
/// Example:
///
/// ```text
/// Expected:
/// slot_0 → 4
/// slot_1 → 8
/// slot_2 → 12
/// ```
///
/// Strategy:
/// - Ensure that the session contains a structure runtime state.
/// - Reject an empty expected solution.
/// - Locate every required slot.
/// - Resolve the node assigned to each slot.
/// - Compare the node value with the expected value.
/// - Return `true` only when every expected slot is correct.
class ExpectedSlotValuesValidationStrategy implements ValidationStrategy {
  /// Expected value for each slot identifier.
  ///
  /// Slots that are not included in this map are not evaluated by this
  /// strategy.
  final Map<String, int> expectedValuesBySlotId;

  const ExpectedSlotValuesValidationStrategy({
    required this.expectedValuesBySlotId,
  });

  /// Validates whether all expected slots contain their required values.
  ///
  /// Returns `false` when:
  ///
  /// - the challenge does not use a structure runtime state;
  /// - no expected slot values were configured;
  /// - an expected slot does not exist;
  /// - an expected slot is empty;
  /// - the assigned node does not exist;
  /// - a node contains a different value.
  @override
  bool isSolved(ChallengeSession session) {
    final runtimeState = session.runtimeState;

    if (runtimeState is! StructureRuntimeState) {
      return false;
    }

    final state = runtimeState.structure;

    if (expectedValuesBySlotId.isEmpty) {
      return false;
    }

    for (final entry in expectedValuesBySlotId.entries) {
      final slotId = entry.key;
      final expectedValue = entry.value;

      final slot = state.slots[slotId];

      if (slot == null) {
        return false;
      }

      final filledNodeId = slot.filledNodeId;

      if (filledNodeId == null) {
        return false;
      }

      final node = state.nodes[filledNodeId];

      if (node == null) {
        return false;
      }

      if (node.value != expectedValue) {
        return false;
      }
    }

    return true;
  }
}
