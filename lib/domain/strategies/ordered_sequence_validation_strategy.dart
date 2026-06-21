import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

/// Validation strategy that verifies whether the values assigned to the slots
/// form an ordered sequence.
///
/// Slots are evaluated according to their [SlotState.index]. After resolving
/// the node assigned to each slot, their values must appear in non-decreasing
/// order.
///
/// This means that:
///
/// - every slot must be filled;
/// - every filled slot must reference an existing node;
/// - every referenced node must contain a value;
/// - each value must be greater than or equal to the previous value.
///
/// Equal consecutive values are allowed.
///
/// Example of a valid sequence:
///
/// ```text
/// 2, 4, 4, 7, 10
/// ```
///
/// Example of an invalid sequence:
///
/// ```text
/// 2, 6, 4, 9
/// ```
///
/// Strategy:
/// - Ensure that the session contains a structure runtime state.
/// - Reject structures without slots.
/// - Sort the slots by their logical index.
/// - Resolve the value assigned to every slot.
/// - Reject empty slots or invalid node references.
/// - Verify that the resulting sequence is non-decreasing.
class OrderedSequenceValidationStrategy implements ValidationStrategy {
  const OrderedSequenceValidationStrategy();

  /// Validates whether the slot values form a non-decreasing sequence.
  ///
  /// Returns `false` when:
  ///
  /// - the challenge does not use a structure runtime state;
  /// - the structure contains no slots;
  /// - a slot is not filled;
  /// - a slot references an unknown node;
  /// - a referenced node has no value;
  /// - a value is smaller than the previous value.
  @override
  bool isSolved(ChallengeSession session) {
    final runtimeState = session.runtimeState;

    if (runtimeState is! StructureRuntimeState) {
      return false;
    }

    final state = runtimeState.structure;

    if (state.slots.isEmpty) {
      return false;
    }

    final slots = state.slots.values;

    // Every slot must define a logical position.
    if (slots.any((slot) => slot.index == null)) {
      return false;
    }

    // Slot indexes must be unique to avoid an ambiguous sequence order.
    final indexes = slots.map((slot) => slot.index!).toList(growable: false);

    if (indexes.toSet().length != indexes.length) {
      return false;
    }

    final orderedSlots = slots.toList()
      ..sort((a, b) => a.index!.compareTo(b.index!));

    final values = <int>[];

    // Resolve the value assigned to every slot in sequence order.
    for (final slot in orderedSlots) {
      final filledNodeId = slot.filledNodeId;

      if (filledNodeId == null) {
        return false;
      }

      final node = state.nodes[filledNodeId];

      if (node == null || node.value == null) {
        return false;
      }

      values.add(node.value!);
    }

    // The sequence must be non-decreasing.
    for (var i = 1; i < values.length; i++) {
      if (values[i - 1] > values[i]) {
        return false;
      }
    }

    return true;
  }
}
