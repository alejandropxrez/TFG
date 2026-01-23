import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'user_progress_model.freezed.dart';
part 'user_progress_model.g.dart';

@freezed
@HiveType(typeId: 1)
abstract class UserProgressModel with _$UserProgressModel {
  const factory UserProgressModel({
    @HiveField(0) required String userId,
    @HiveField(1) required int level,
    @HiveField(2) required double experiencePoints,
    @HiveField(3) required int livesRemaining,
    @HiveField(4) required List<String> unlockedLevels,
    @HiveField(5) String? currentLevelId,
  }) = _UserProgressModel;
}
