import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';

@freezed
abstract class UserProgress with _$UserProgress {
  const factory UserProgress({
    // The unique identifier for the user.
    required String userId,

    // The current level of the user.
    required int level,

    // The total experience points accumulated by the user.
    required double experiencePoints,

    // The number of lives remaining for the user.
    required int livesRemaining,

    // A set of levels that the user has unlocked.
    required Set<String> unlockedLevels,

    // The ID of the current level the user is on, if any.
    String? currentLevelId,
  }) = _UserProgress;
}
