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
    final currentState = session.currentState;

    if (!action.isApplicableTo(currentState)) {
      return session;
    }

    if (!_satisfiesConstraints(session, action)) {
      return session;
    }

    final nextState = action.transform(currentState);

    return session.copyWith(
      currentState: nextState,
      history: [...session.history, currentState],
      movesUsed: session.movesUsed + 1,
      updatedAt: DateTime.now(),
      status: SessionStatus.inProgress,
    );
  }

  bool _satisfiesConstraints(ChallengeSession session, GameAction action) {
    for (final constraint in session.spec.engineConfig.constraints) {
      if (constraint is MaxMovesConstraint) {
        if (session.movesUsed >= constraint.maxMoves) {
          return false;
        }
      }

      if (constraint is LockedNodesConstraint) {
        if (action case SwapNodesAction(
          :final firstNodeId,
          :final secondNodeId,
        )) {
          if (constraint.nodeIds.contains(firstNodeId) ||
              constraint.nodeIds.contains(secondNodeId)) {
            return false;
          }
        }

        if (action case SetValueAction(:final slotId)) {
          if (constraint.nodeIds.contains(slotId)) {
            return false;
          }
        }
      }
    }

    return true;
  }
}
