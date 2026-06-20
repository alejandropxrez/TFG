import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/application_state/learning_path_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final learningPathProvider =
    AsyncNotifierProvider<LearningPathNotifier, LearningPathState>(
      LearningPathNotifier.new,
      retry: (_, _) => null,
    );

class LearningPathNotifier extends AsyncNotifier<LearningPathState> {
  @override
  Future<LearningPathState> build() async {
    final dependencies = ref.watch(learningPathDependenciesProvider);
    final userId = ref.watch(currentUserIdProvider);
    final learningPath = await dependencies.loadLearningPath(userId);
    return LearningPathState.loaded(learningPath);
  }
}
