import '../../domain/entities/user_progress.dart';
import '../models/user_progress_model.dart';

class UserProgressMapper {
  static UserProgress toDomain(UserProgressModel model) {
    return UserProgress(
      userId: model.userId,
      level: model.level,
      experiencePoints: model.experiencePoints,
      livesRemaining: model.livesRemaining,
      unlockedLevels: Set<String>.from(model.unlockedLevels),
      currentLevelId: model.currentLevelId,
    );
  }

  static UserProgressModel toModel(UserProgress entity) {
    return UserProgressModel(
      userId: entity.userId,
      level: entity.level,
      experiencePoints: entity.experiencePoints,
      livesRemaining: entity.livesRemaining,
      unlockedLevels: entity.unlockedLevels.toList(),
      currentLevelId: entity.currentLevelId,
    );
  }
}
