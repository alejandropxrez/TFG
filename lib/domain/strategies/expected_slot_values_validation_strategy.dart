import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

class ExpectedSlotValuesValidationStrategy implements ValidationStrategy {
  final Map<String, int> expectedValuesBySlotId;

  const ExpectedSlotValuesValidationStrategy({
    required this.expectedValuesBySlotId,
  });

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
