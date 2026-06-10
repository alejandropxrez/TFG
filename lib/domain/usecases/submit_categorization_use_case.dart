import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';

class SubmitCategorizationUseCase {
  const SubmitCategorizationUseCase();

  ChallengeSession call({
    required ChallengeSession session,
    required String itemId,
    required String categoryId,
  }) {
    final runtimeState = session.runtimeState;

    if (runtimeState is! CategorizeRuntimeState) {
      return session;
    }

    return session.copyWith(
      runtimeState: runtimeState.copyWith(
        selectedCategoryByItemId: {
          ...runtimeState.selectedCategoryByItemId,
          itemId: categoryId,
        },
      ),
      updatedAt: DateTime.now(),
    );
  }
}
