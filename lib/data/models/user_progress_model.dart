class UserProgressModel {
  final String userId;
  final int level;
  final double experiencePoints;
  final int livesRemaining;
  final List<String> unlockedLevels;
  final String? currentLevelId;

  const UserProgressModel({
    required this.userId,
    required this.level,
    required this.experiencePoints,
    required this.livesRemaining,
    required this.unlockedLevels,
    this.currentLevelId,
  });
}
