import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress_model.freezed.dart';

// todo: hive type.

@freezed
abstract class UserProgressModel with _$UserProgressModel {
  const factory UserProgressModel({
    required String userId,
    required int level,
    required double experiencePoints,
    required int livesRemaining,
    required List<String> unlockedLevels,
    String? currentLevelId,
  }) = _UserProgressModel;
}
