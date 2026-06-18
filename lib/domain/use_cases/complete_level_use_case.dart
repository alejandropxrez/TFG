import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/use_cases/manage_progress_use_case.dart';

typedef LoadUserProgress = Future<UserProgress?> Function(String userId);
typedef SaveUserProgress = Future<void> Function(UserProgress progress);
typedef GetNextLevelId = Future<String?> Function(String currentLevelId);

class CompleteLevelProgressUseCase {
  final LoadUserProgress loadUserProgress;
  final SaveUserProgress saveProgress;
  final GetNextLevelId getNextLevelId;
  final ManageProgressUseCase manageProgress;

  const CompleteLevelProgressUseCase({
    required this.loadUserProgress,
    required this.saveProgress,
    required this.getNextLevelId,
    required this.manageProgress,
  });

  Future<UserProgress> call({
    required String userId,
    required LevelSyllabus syllabus,
  }) async {
    final currentProgress = await loadUserProgress(userId);

    final baseProgress =
        currentProgress ??
        UserProgress(
          userId: userId,
          level: 1,
          experiencePoints: 0,
          livesRemaining: 5,
          unlockedLevels: {syllabus.id},
          currentLevelId: syllabus.id,
        );

    final nextLevelId = await getNextLevelId(syllabus.id);

    final updatedProgress = manageProgress.completeLevel(
      current: baseProgress,
      completedLevelId: syllabus.id,
      xpReward: syllabus.rewards.xp,
      nextLevelId: nextLevelId,
      livesGained: syllabus.rewards.lives,
    );

    await saveProgress(updatedProgress);

    return updatedProgress;
  }
}
