import '../entities/challenge_session.dart';
import '../entities/game_action.dart';
import '../entities/challenge_spec.dart';
import '../enums/session_status.dart';

class ExecuteMoveUseCase {
  const ExecuteMoveUseCase();

  ChallengeSession call({
    required ChallengeSession session,
    required GameAction action,
  }) {
    final currentState = session.currentState;

    // 1. Check if action can be applied to the current structure
    if (!action.isApplicableTo(currentState)) {
      return session;
    }

    // 2. Check challenge constraints
    if (!_satisfiesConstraints(session, action)) {
      return session;
    }

    // 3. Apply transformation
    final nextState = action.transform(currentState);

    // 4. Return updated session
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

        if (action case SetNodeValueAction(:final nodeId)) {
          if (constraint.nodeIds.contains(nodeId)) {
            return false;
          }
        }
      }
    }

    return true;
  }
}
