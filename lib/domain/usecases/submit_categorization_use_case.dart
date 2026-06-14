import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';

class SubmitCategorizationUseCase {
  const SubmitCategorizationUseCase();

  ChallengeSession call({
    required ChallengeSession session,
    required String itemId,
    required String categoryId,
  }) {
    final content = session.spec.content;
    final runtimeState = session.runtimeState;

    if (content is! CategorizeChallengeContent ||
        runtimeState is! CategorizeRuntimeState) {
      return session;
    }

    final validItemIds = content.categorizeSpec.items
        .map((item) => item.id)
        .toSet();

    if (!validItemIds.contains(itemId)) {
      return session;
    }

    final validCategoryIds = content.categorizeSpec.categories
        .map((category) => category.id)
        .toSet();

    if (!validCategoryIds.contains(categoryId)) {
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
