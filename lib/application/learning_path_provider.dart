import 'dart:convert';

import 'package:algoquest/application/app_providers.dart';
import 'package:algoquest/application/learning_path_state.dart';
import 'package:flutter/services.dart';
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

      final jsonString = await rootBundle.loadString(
        'assets/data/syllabus.json',
      );

      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final phasesJson = decoded['phases'] as List<dynamic>;

      final userProgress = await useCases.loadUserProgress(userId);
      final unlockedLevels = userProgress?.unlockedLevels ?? const <String>{};

      var globalLevelIndex = 0;

      final phases = phasesJson
          .map((phaseJson) {
            final phaseMap = phaseJson as Map<String, dynamic>;
            final levelsJson = phaseMap['levels'] as List<dynamic>;

            final levels = levelsJson
                .map((levelJson) {
                  final levelMap = levelJson as Map<String, dynamic>;
                  final levelId = levelMap['id'] as String;

                  final isFirstLevel = globalLevelIndex == 0;

                  final locked =
                      !isFirstLevel && !unlockedLevels.contains(levelId);

                  globalLevelIndex++;

                  return LearningPathLevelItem.fromJson(
                    levelMap,
                    locked: locked,
                  );
                })
                .toList(growable: false);

            return LearningPathPhaseItem(
              id: phaseMap['id'] as String,
              title: phaseMap['title'] as String,
              levels: levels,
            );
          })
          .toList(growable: false);

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
