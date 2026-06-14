import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/quiz_action.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class SubmitQuizAnswerUseCase {
  const SubmitQuizAnswerUseCase();

  ChallengeSession call({
    required ChallengeSession session,
    required SubmitQuizAnswerAction action,
  }) {
    final content = session.spec.content;
    final runtimeState = session.runtimeState;

    if (content is! QuizChallengeContent || runtimeState is! QuizRuntimeState) {
      return session;
    }

    final selected = action.selectedOptionIds;

    if (selected.isEmpty) {
      return session;
    }

    if (content.quizSpec.isSingleChoice && selected.length != 1) {
      return session;
    }

    final validOptionIds = content.quizSpec.options
        .map((option) => option.id)
        .toSet();

    if (!validOptionIds.containsAll(selected)) {
      return session;
    }

    return session.copyWith(
      runtimeState: runtimeState.copyWith(
        selectedOptionIds: selected,
        submitted: true,
      ),
      status: SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
