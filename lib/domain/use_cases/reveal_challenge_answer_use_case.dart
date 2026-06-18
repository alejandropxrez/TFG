import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';

class RevealChallengeAnswerUseCase {
  ChallengeSession call({
    required ChallengeSpec spec,
    required ChallengeSession session,
  }) {
    if (!session.hasNoAttemptsRemaining) {
      return session;
    }

    final updatedRuntimeState = switch ((spec.content, session.runtimeState)) {
      (
        QuizChallengeContent(:final quizSpec),
        final QuizRuntimeState runtimeState,
      ) =>
        runtimeState.copyWith(
          selectedOptionIds: quizSpec.correctOptionIds,
          submitted: true,
        ),

      (
        IdentifyTargetChallengeContent(:final identifySpec),
        final IdentifyTargetRuntimeState runtimeState,
      ) =>
        runtimeState.copyWith(
          selectedTargetIds: identifySpec.correctTargetIds,
          submitted: true,
        ),

      (
        CategorizeChallengeContent(:final categorizeSpec),
        final CategorizeRuntimeState runtimeState,
      ) =>
        runtimeState.copyWith(
          selectedCategoryByItemId: categorizeSpec.correctCategoryByItemId,
        ),

      _ => session.runtimeState,
    };

    if (updatedRuntimeState == session.runtimeState) {
      return session;
    }

    return session.copyWith(runtimeState: updatedRuntimeState);
  }
}
