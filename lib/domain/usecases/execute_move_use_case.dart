import 'package:algoquest/domain/entities/challenge_session.dart';

import 'package:algoquest/domain/entities/game_action.dart';

class ExecuteMoveUseCase {
  const ExecuteMoveUseCase();

  ChallengeSession call({
    required ChallengeSession session,
    required GameAction action,
  }) {
    // Very first version: only track movesUsed and apply minimal state changes.
    // Real rules can be added later per InteractionMode/constraints.
    final nextMoves = session.movesUsed + 1;

    // Apply action
    final updated = switch (action) {
      SwapNodesAction(:final aId, :final bId) => _applySwap(session, aId, bId),
      DragNodeToSlotAction(:final nodeId, :final slotId) => _applyDragToSlot(
        session,
        nodeId,
        slotId,
      ),
    };

    return updated.copyWith(movesUsed: nextMoves);
  }

  ChallengeSession _applySwap(
    ChallengeSession session,
    String aId,
    String bId,
  ) {
    final nodes = session.nodes.toList();

    final aIndex = nodes.indexWhere((n) => n.id == aId);
    final bIndex = nodes.indexWhere((n) => n.id == bId);

    if (aIndex == -1 || bIndex == -1) return session;

    final a = nodes[aIndex];
    final b = nodes[bIndex];

    nodes[aIndex] = a.copyWith(value: b.value);
    nodes[bIndex] = b.copyWith(value: a.value);

    return session.copyWith(nodes: nodes);
  }

  ChallengeSession _applyDragToSlot(
    ChallengeSession session,
    String nodeId,
    String slotId,
  ) {
    final slots = session.slots.toList();
    final sIndex = slots.indexWhere((s) => s.id == slotId);
    if (sIndex == -1) return session;

    slots[sIndex] = slots[sIndex].copyWith(filledNodeId: nodeId);
    return session.copyWith(slots: slots);
  }
}
