import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class CheckCategorizationUseCase {
  const CheckCategorizationUseCase();

  ChallengeSession call(ChallengeSession session) {
    final content = session.spec.content;
    final runtimeState = session.runtimeState;

    if (content is! CategorizeChallengeContent ||
        runtimeState is! CategorizeRuntimeState) {
      return session;
    }

    final expected = content.categorizeSpec.correctCategoryByItemId;
    final actual = runtimeState.selectedCategoryByItemId;

    final solved =
        actual.length == expected.length &&
        expected.entries.every((entry) => actual[entry.key] == entry.value);

    return session.copyWith(
      status: solved ? SessionStatus.completed : SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
