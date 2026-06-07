import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class CheckQuizAnswerUseCase {
  const CheckQuizAnswerUseCase();

  ChallengeSession call(ChallengeSession session) {
    final content = session.spec.content;
    final runtimeState = session.runtimeState;

    if (content is! QuizChallengeContent || runtimeState is! QuizRuntimeState) {
      return session;
    }

    if (!runtimeState.submitted) {
      return session;
    }

    final isCorrect =
        runtimeState.selectedOptionIds.length ==
            content.quizSpec.correctOptionIds.length &&
        runtimeState.selectedOptionIds.containsAll(
          content.quizSpec.correctOptionIds,
        );

    return session.copyWith(
      status: isCorrect ? SessionStatus.completed : SessionStatus.failed,
      updatedAt: DateTime.now(),
    );
  }
}
