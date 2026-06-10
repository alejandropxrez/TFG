import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/data/models/user_progress_model.dart';

class UserProgressMapper {
  static UserProgress toDomain(UserProgressModel model) {
    return UserProgress(
      userId: model.userId,
      level: model.level,
      experiencePoints: model.experiencePoints,
      livesRemaining: model.livesRemaining,
      unlockedLevels: Set<String>.from(model.unlockedLevels),
      completedLevels: Set<String>.from(model.completedLevels),
      currentLevelId: model.currentLevelId,
    );
  }

  static UserProgressModel toModel(UserProgress entity) {
    return UserProgressModel(
      userId: entity.userId,
      level: entity.level,
      experiencePoints: entity.experiencePoints,
      livesRemaining: entity.livesRemaining,
      unlockedLevels: entity.unlockedLevels.toSet(),
      completedLevels: entity.completedLevels.toSet(),
      currentLevelId: entity.currentLevelId,
    );
  }
}
