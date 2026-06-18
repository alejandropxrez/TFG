import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class ExecuteMoveUseCase {
  const ExecuteMoveUseCase();

  ChallengeSession call({
    required ChallengeSession session,
    required GameAction action,
  }) {
    final runtimeState = session.runtimeState;

    if (runtimeState is! StructureRuntimeState) {
      return session;
    }

    final currentStructure = runtimeState.structure;

    if (!_isActionAllowedByInteractionMode(session, action)) {
      return session;
    }

    if (!action.isApplicableTo(currentStructure)) {
      return session;
    }

    if (!_satisfiesConstraints(session, action, runtimeState)) {
      return session;
    }

    final nextStructure = action.transform(currentStructure);

    return session.copyWith(
      runtimeState: runtimeState.copyWith(
        structure: nextStructure,
        history: [...runtimeState.history, currentStructure],
        redoStack: const [],
        movesUsed: runtimeState.movesUsed + 1,
      ),
      updatedAt: DateTime.now(),
      status: SessionStatus.inProgress,
    );
  }

  bool _satisfiesConstraints(
    ChallengeSession session,
    GameAction action,
    StructureRuntimeState runtimeState,
  ) {
    for (final constraint in session.spec.constraints) {
      if (constraint is MaxMovesConstraint) {
        if (runtimeState.movesUsed >= constraint.maxMoves) {
          return false;
        }
      }

      if (constraint is LockedNodesConstraint) {
        if (action is SwapNodesAction) {
          if (constraint.nodeIds.contains(action.firstNodeId) ||
              constraint.nodeIds.contains(action.secondNodeId)) {
            return false;
          }
        }

        if (action is SetValueAction) {
          if (constraint.nodeIds.contains(action.slotId)) {
            return false;
          }
        }

        if (action is LinkAction) {
          if (constraint.nodeIds.contains(action.sourceNodeId) ||
              constraint.nodeIds.contains(action.targetNodeId)) {
            return false;
          }
        }

        if (action is RemoveLinkAction) {
          if (constraint.nodeIds.contains(action.sourceNodeId) ||
              constraint.nodeIds.contains(action.targetNodeId)) {
            return false;
          }
        }

        if (action is ClearSlotAction) {
          if (constraint.nodeIds.contains(action.slotId)) {
            return false;
          }
        }
      }
    }

    return true;
  }

  bool _isActionAllowedByInteractionMode(
    ChallengeSession session,
    GameAction action,
  ) {
    final mode = session.spec.engineConfig.interactionMode;

    switch (mode) {
      case InteractionModeType.swap:
        return action is SwapNodesAction;
      case InteractionModeType.setValue:
        return action is SetValueAction || action is ClearSlotAction;
      case InteractionModeType.drag:
        return action is SetValueAction || action is ClearSlotAction;
      case InteractionModeType.link:
        return action is LinkAction || action is RemoveLinkAction;
    }
  }
}
