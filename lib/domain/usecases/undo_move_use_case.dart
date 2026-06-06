import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class UndoMoveUseCase {
  const UndoMoveUseCase();

  ChallengeSession call(ChallengeSession session) {
    if (session.history.isEmpty) {
      return session;
    }

    final previousState = session.history.last;
    final updatedHistory = session.history.sublist(
      0,
      session.history.length - 1,
    );

    return session.copyWith(
      currentState: previousState,
      history: updatedHistory,
      redoStack: [...session.redoStack, session.currentState],
      movesUsed: session.movesUsed > 0 ? session.movesUsed - 1 : 0,
      status: SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
