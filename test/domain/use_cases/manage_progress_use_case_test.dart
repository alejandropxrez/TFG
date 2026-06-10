import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/usecases/manage_progress_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("applyRewards", () {
    test('applyRewards increases lives when livesGained is provided', () {
      const useCase = ManageProgressUseCase();

      const current = UserProgress(
        userId: 'user_1',
        level: 1,
        experiencePoints: 100.0,
        livesRemaining: 2,
        unlockedLevels: {'level_heap_intro'},
        currentLevelId: 'level_heap_intro',
      );

      final updated = useCase.applyRewards(
        current: current,
        xpGained: 50,
        livesGained: 1,
      );

      expect(updated.experiencePoints, 150.0);
      expect(updated.livesRemaining, 3);
      expect(updated.level, 1);
      expect(updated.unlockedLevels, {'level_heap_intro'});
      expect(updated.currentLevelId, 'level_heap_intro');
    });

    test('applyRewards keeps lives unchanged when livesGained is omitted', () {
      const useCase = ManageProgressUseCase();

      const current = UserProgress(
        userId: 'user_1',
        level: 1,
        experiencePoints: 100.0,
        livesRemaining: 2,
        unlockedLevels: {'level_heap_intro'},
        currentLevelId: 'level_heap_intro',
      );

      final updated = useCase.applyRewards(current: current, xpGained: 50);

      expect(updated.experiencePoints, 150.0);
      expect(updated.livesRemaining, 2);
      expect(updated.level, 1);
      expect(updated.unlockedLevels, {'level_heap_intro'});
      expect(updated.currentLevelId, 'level_heap_intro');
    });

    test('applyRewards unlocks new levels and updates current level id', () {
      const useCase = ManageProgressUseCase();

      const current = UserProgress(
        userId: 'user_1',
        level: 1,
        experiencePoints: 100.0,
        livesRemaining: 2,
        unlockedLevels: {'level_heap_intro'},
        currentLevelId: 'level_heap_intro',
      );

      final updated = useCase.applyRewards(
        current: current,
        xpGained: 50,
        livesGained: 1,
        newlyUnlockedLevels: {'level_bst_intro'},
        newCurrentLevelId: 'level_bst_intro',
      );

      expect(updated.experiencePoints, 150.0);
      expect(updated.livesRemaining, 3);
      expect(updated.unlockedLevels, {'level_heap_intro', 'level_bst_intro'});
      expect(updated.currentLevelId, 'level_bst_intro');
    });
  });
  group('completeLevel', () {
    test(
      'marks level as completed, unlocks next level, and applies rewards',
      () {
        const useCase = ManageProgressUseCase();

        const current = UserProgress(
          userId: 'user_1',
          level: 1,
          experiencePoints: 100.0,
          livesRemaining: 2,
          unlockedLevels: {'level_heap_intro'},
          completedLevels: {},
          currentLevelId: 'level_heap_intro',
        );

        final updated = useCase.completeLevel(
          current: current,
          completedLevelId: 'level_heap_intro',
          xpReward: 50,
          nextLevelId: 'level_bst_intro',
          livesGained: 1,
        );

        expect(updated.completedLevels, {'level_heap_intro'});
        expect(updated.unlockedLevels, {'level_heap_intro', 'level_bst_intro'});
        expect(updated.experiencePoints, 150.0);
        expect(updated.livesRemaining, 3);
        expect(updated.currentLevelId, 'level_bst_intro');
      },
    );

    test('does not duplicate rewards when level was already completed', () {
      const useCase = ManageProgressUseCase();

      const current = UserProgress(
        userId: 'user_1',
        level: 1,
        experiencePoints: 100.0,
        livesRemaining: 2,
        unlockedLevels: {'level_heap_intro', 'level_bst_intro'},
        completedLevels: {'level_heap_intro'},
        currentLevelId: 'level_bst_intro',
      );

      final updated = useCase.completeLevel(
        current: current,
        completedLevelId: 'level_heap_intro',
        xpReward: 50,
        nextLevelId: 'level_bst_intro',
        livesGained: 1,
      );

      expect(updated.completedLevels, {'level_heap_intro'});
      expect(updated.unlockedLevels, {'level_heap_intro', 'level_bst_intro'});
      expect(updated.experiencePoints, 100.0);
      expect(updated.livesRemaining, 2);
      expect(updated.currentLevelId, 'level_bst_intro');
    });

    test('marks final level as completed without unlocking a next level', () {
      const useCase = ManageProgressUseCase();

      const current = UserProgress(
        userId: 'user_1',
        level: 1,
        experiencePoints: 100.0,
        livesRemaining: 2,
        unlockedLevels: {'level_graph_final'},
        completedLevels: {},
        currentLevelId: 'level_graph_final',
      );

      final updated = useCase.completeLevel(
        current: current,
        completedLevelId: 'level_graph_final',
        xpReward: 75,
        nextLevelId: null,
        livesGained: 0,
      );

      expect(updated.completedLevels, {'level_graph_final'});
      expect(updated.unlockedLevels, {'level_graph_final'});
      expect(updated.experiencePoints, 175.0);
      expect(updated.livesRemaining, 2);
      expect(updated.currentLevelId, 'level_graph_final');
    });
  });
}
