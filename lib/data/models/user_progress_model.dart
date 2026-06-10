class UserProgressModel {
  final String userId;
  final int level;
  final double experiencePoints;
  final int livesRemaining;
  final Set<String> unlockedLevels;
  final Set<String> completedLevels;
  final String? currentLevelId;

  const UserProgressModel({
    required this.userId,
    required this.level,
    required this.experiencePoints,
    required this.livesRemaining,
    required this.unlockedLevels,
    required this.completedLevels,
    this.currentLevelId,
  });
}
