import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class RedoMoveUseCase {
  const RedoMoveUseCase();

  ChallengeSession call(ChallengeSession session) {
    final runtimeState = session.runtimeState;

    if (runtimeState is! StructureRuntimeState) {
      return session;
    }

    if (runtimeState.redoStack.isEmpty) {
      return session;
    }

    final nextStructure = runtimeState.redoStack.last;
    final updatedRedoStack = runtimeState.redoStack.sublist(
      0,
      runtimeState.redoStack.length - 1,
    );

    return session.copyWith(
      runtimeState: runtimeState.copyWith(
        structure: nextStructure,
        history: [...runtimeState.history, runtimeState.structure],
        redoStack: updatedRedoStack,
        movesUsed: runtimeState.movesUsed + 1,
      ),
      status: SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
