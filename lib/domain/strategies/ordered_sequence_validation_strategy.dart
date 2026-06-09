import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

class OrderedSequenceValidationStrategy implements ValidationStrategy {
  const OrderedSequenceValidationStrategy();

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

    final orderedSlots = state.slots.values.toList()
      ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

    final values = <int>[];

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

    for (var i = 1; i < values.length; i++) {
      if (values[i - 1] > values[i]) {
        return false;
      }
    }

    return true;
  }
}
