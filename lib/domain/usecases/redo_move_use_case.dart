import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class RedoMoveUseCase {
  const RedoMoveUseCase();

  ChallengeSession call(ChallengeSession session) {
    if (session.redoStack.isEmpty) {
      return session;
    }

    final nextState = session.redoStack.last;

    final updatedRedoStack = session.redoStack.sublist(
      0,
      session.redoStack.length - 1,
    );

    return session.copyWith(
      currentState: nextState,
      history: [...session.history, session.currentState],
      redoStack: updatedRedoStack,
      movesUsed: session.movesUsed + 1,
      status: SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
