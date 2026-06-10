import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';

@freezed
abstract class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String userId,
    required int level,
    required double experiencePoints,
    required int livesRemaining,
    required Set<String> unlockedLevels,
    @Default(<String>{}) Set<String> completedLevels,
    String? currentLevelId,
  }) = _UserProgress;
}
