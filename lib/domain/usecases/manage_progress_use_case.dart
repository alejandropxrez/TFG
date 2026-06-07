import 'package:algoquest/domain/entities/user_progress.dart';

class ManageProgressUseCase {
  const ManageProgressUseCase();

  /// Apply rewards after completing a level/challenge.
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
