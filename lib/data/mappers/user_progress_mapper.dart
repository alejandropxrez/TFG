import 'package:algoquest/domain/entities/user_progress.dart';

import 'package:algoquest/data/models/user_progress_model.dart';

/// Maps between the domain entity [UserProgress] and the data model [UserProgressModel].
///
/// Rationale:
/// - Domain uses rich types like Set for business semantics (unique unlocked levels).
/// - Data model uses IO-friendly types like List for JSON/Hive compatibility.
class UserProgressMapper {
  static UserProgress toEntity(UserProgressModel model) {
    return UserProgress(
      userId: model.userId,
      level: model.level,
      experiencePoints: model.experiencePoints,
      livesRemaining: model.livesRemaining,
      unlockedLevels: model.unlockedLevels.toSet(),
      currentLevelId: model.currentLevelId,
    );
  }

  static UserProgressModel toModel(UserProgress entity) {
    // Sorting makes persistence deterministic (nice for tests/debugging).
    final unlocked = entity.unlockedLevels.toList()..sort();

    return UserProgressModel(
      userId: entity.userId,
      level: entity.level,
      experiencePoints: entity.experiencePoints,
      livesRemaining: entity.livesRemaining,
      unlockedLevels: unlocked,
      currentLevelId: entity.currentLevelId,
    );
  }
}
