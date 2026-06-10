import 'package:algoquest/data/datasources/local/drift/app_database.dart';
import 'package:algoquest/data/models/user_progress_model.dart';
import 'package:drift/drift.dart';

class UserProgressDriftMapper {
  static UserProgressModel toModel(UserProgressTableData row) {
    return UserProgressModel(
      userId: row.userId,
      level: row.level,
      experiencePoints: row.experiencePoints,
      livesRemaining: row.livesRemaining,
      unlockedLevels: row.unlockedLevels.toSet(),
      completedLevels: row.completedLevels.toSet(),
      currentLevelId: row.currentLevelId,
    );
  }

  static UserProgressTableCompanion toCompanion(UserProgressModel model) {
    return UserProgressTableCompanion(
      userId: Value(model.userId),
      level: Value(model.level),
      experiencePoints: Value(model.experiencePoints),
      livesRemaining: Value(model.livesRemaining),
      unlockedLevels: Value(model.unlockedLevels.toList()),
      completedLevels: Value(model.completedLevels.toList()),
      currentLevelId: Value(model.currentLevelId),
    );
  }
}
