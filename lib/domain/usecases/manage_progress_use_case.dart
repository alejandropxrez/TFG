import '../entities/user_progress.dart';

class ManageProgressUseCase {
  const ManageProgressUseCase();

  /// Apply rewards after completing a level/challenge.
  UserProgress applyRewards({
    required UserProgress current,
    required int xpGained,
    Set<String> newlyUnlockedLevels = const {},
    String? newCurrentLevelId,
  }) {
    return current.copyWith(
      experiencePoints: current.experiencePoints + xpGained,
      unlockedLevels: {...current.unlockedLevels, ...newlyUnlockedLevels},
      currentLevelId: newCurrentLevelId ?? current.currentLevelId,
    );
  }
}
