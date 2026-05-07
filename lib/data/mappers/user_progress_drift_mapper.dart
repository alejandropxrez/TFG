import 'package:algoquest/data/datasources/local/drift/app_database.dart';
import 'package:algoquest/data/models/user_progress_model.dart';
import 'package:drift/drift.dart';

class UserProgressDriftMapper {
  static UserProgressModel toModel(UserProgressTableData data) {
    return UserProgressModel(
      userId: data.userId,
      level: data.level,
      experiencePoints: data.experiencePoints,
      livesRemaining: data.livesRemaining,
      unlockedLevels: data.unlockedLevels,
      currentLevelId: data.currentLevelId,
    );
  }

  static UserProgressTableCompanion toCompanion(UserProgressModel model) {
    return UserProgressTableCompanion(
      userId: Value(model.userId),
      level: Value(model.level),
      experiencePoints: Value(model.experiencePoints),
      livesRemaining: Value(model.livesRemaining),
      unlockedLevels: Value(model.unlockedLevels),
      currentLevelId: Value(model.currentLevelId),
    );
  }
}
