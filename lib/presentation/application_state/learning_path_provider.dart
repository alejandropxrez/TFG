import 'dart:convert';

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
      final loadSyllabusJson = ref.read(syllabusJsonLoaderProvider);
      final loadLevelJson = ref.read(levelJsonLoaderProvider);

      final jsonString = await loadSyllabusJson();

      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final phasesJson = decoded['phases'] as List<dynamic>;

      final userProgress = await useCases.loadUserProgress(userId);
      final unlockedLevels = userProgress?.unlockedLevels ?? const <String>{};

      var globalLevelIndex = 0;
      final phases = <LearningPathPhaseItem>[];

      for (final phaseJson in phasesJson) {
        final phaseMap = phaseJson as Map<String, dynamic>;
        final levelsJson = phaseMap['levels'] as List<dynamic>;

        final levels = <LearningPathLevelItem>[];

        for (final levelJson in levelsJson) {
          final levelRefMap = levelJson as Map<String, dynamic>;
          final levelId = levelRefMap['id'] as String;

          final levelJsonString = await loadLevelJson(levelId);
          final levelMap = json.decode(levelJsonString) as Map<String, dynamic>;

          final isFirstLevel = globalLevelIndex == 0;
          final locked = !isFirstLevel && !unlockedLevels.contains(levelId);

          globalLevelIndex++;

          levels.add(LearningPathLevelItem.fromJson(levelMap, locked: locked));
        }

        phases.add(
          LearningPathPhaseItem(
            id: phaseMap['id'] as String,
            title: phaseMap['title'] as String,
            levels: levels,
          ),
        );
      }

      state = state.copyWith(
        status: LearningPathStatus.loaded,
        title: decoded['title'] as String? ?? 'AlgoQuest',
        phases: phases,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LearningPathStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }
}
