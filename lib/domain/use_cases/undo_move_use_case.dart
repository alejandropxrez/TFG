import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class UndoMoveUseCase {
  const UndoMoveUseCase();

  ChallengeSession call(ChallengeSession session) {
    final runtimeState = session.runtimeState;

    if (runtimeState is! StructureRuntimeState) {
      return session;
    }

    if (runtimeState.history.isEmpty) {
      return session;
    }

    final previousStructure = runtimeState.history.last;
    final updatedHistory = runtimeState.history.sublist(
      0,
      runtimeState.history.length - 1,
    );

    return session.copyWith(
      runtimeState: runtimeState.copyWith(
        structure: previousStructure,
        history: updatedHistory,
        redoStack: [...runtimeState.redoStack, runtimeState.structure],
        movesUsed: runtimeState.movesUsed > 0 ? runtimeState.movesUsed - 1 : 0,
      ),
      status: SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
