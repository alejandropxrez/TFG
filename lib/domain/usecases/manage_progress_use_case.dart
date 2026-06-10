import 'package:algoquest/domain/entities/user_progress.dart';

class ManageProgressUseCase {
  const ManageProgressUseCase();

  UserProgress completeLevel({
    required UserProgress current,
    required String completedLevelId,
    required int xpReward,
    String? nextLevelId,
    int livesGained = 0,
  }) {
    final alreadyCompleted = current.completedLevels.contains(completedLevelId);

    return current.copyWith(
      completedLevels: {...current.completedLevels, completedLevelId},
      unlockedLevels: {
        ...current.unlockedLevels,
        if (nextLevelId != null) nextLevelId,
      },
      experiencePoints: alreadyCompleted
          ? current.experiencePoints
          : current.experiencePoints + xpReward,
      livesRemaining: alreadyCompleted
          ? current.livesRemaining
          : current.livesRemaining + livesGained,
      currentLevelId: nextLevelId ?? current.currentLevelId,
    );
  }

  UserProgress applyRewards({
    required UserProgress current,
    required int xpGained,
    Set<String> newlyUnlockedLevels = const {},
    String? newCurrentLevelId,
    int livesGained = 0,
  }) {
    return current.copyWith(
      experiencePoints: current.experiencePoints + xpGained,
      unlockedLevels: {...current.unlockedLevels, ...newlyUnlockedLevels},
      currentLevelId: newCurrentLevelId ?? current.currentLevelId,
      livesRemaining: current.livesRemaining + livesGained,
    );
  }
}
