import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class CheckIdentifyTargetUseCase {
  const CheckIdentifyTargetUseCase();

  ChallengeSession call(ChallengeSession session) {
    final content = session.spec.content;
    final runtimeState = session.runtimeState;

    if (content is! IdentifyTargetChallengeContent ||
        runtimeState is! IdentifyTargetRuntimeState) {
      return session;
    }

    if (!runtimeState.submitted) {
      return session;
    }

    final isCorrect =
        runtimeState.selectedTargetIds.length ==
            content.identifySpec.correctTargetIds.length &&
        runtimeState.selectedTargetIds.containsAll(
          content.identifySpec.correctTargetIds,
        );

    return session.copyWith(
      status: isCorrect ? SessionStatus.completed : SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
