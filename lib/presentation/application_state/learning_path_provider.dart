import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/application_state/learning_path_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final learningPathProvider =
    NotifierProvider<LearningPathNotifier, LearningPathState>(
      LearningPathNotifier.new,
    );

class LearningPathNotifier extends Notifier<LearningPathState> {
  @override
  LearningPathState build() {
    return const LearningPathState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(
      status: LearningPathStatus.loading,
      clearError: true,
    );

    try {
      final useCases = ref.read(useCasesProvider);
      final userId = ref.read(currentUserIdProvider);

      final learningPath = await useCases.loadLearningPath(userId);

      state = LearningPathState.loaded(learningPath);
    } catch (error) {
      state = state.copyWith(
        status: LearningPathStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }
}
