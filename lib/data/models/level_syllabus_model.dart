import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_syllabus_model.freezed.dart';
part 'level_syllabus_model.g.dart';

/// Topic/category for UI styling.
enum LevelTopic { heaps, lists, bst, mixed }

@freezed
abstract class LevelSyllabusModel with _$LevelSyllabusModel {
  const factory LevelSyllabusModel({
    /// Unique identifier of the level (e.g., "level_bst_insertion").
    required String id,

    /// User-facing title (e.g., "Inserción en BST").
    required String title,

    /// Short supporting text used in the learning path.
    @Default('') String subtitle,

    /// Topic used by the UI (HEAPS | LISTS | BST | MIXED).
    @JsonKey(fromJson: _topicFromJson, toJson: _topicToJson)
    required LevelTopic topic,

    /// Optional theory shown before starting the practice challenges.
    LevelTheoryModel? theory,

    /// Ordered list of challenge IDs.
    required List<String> challenges,

    /// Rewards granted upon completion.
    required RewardsModel rewards,
  }) = _LevelSyllabusModel;

  factory LevelSyllabusModel.fromJson(Map<String, dynamic> json) =>
      _$LevelSyllabusModelFromJson(json);
}

@freezed
abstract class LevelTheoryModel with _$LevelTheoryModel {
  const factory LevelTheoryModel({
    required String id,
    required String title,
    required String content,
    @Default(<String>[]) List<String> keyPoints,
  }) = _LevelTheoryModel;

  factory LevelTheoryModel.fromJson(Map<String, dynamic> json) =>
      _$LevelTheoryModelFromJson(json);
}

@freezed
abstract class RewardsModel with _$RewardsModel {
  const factory RewardsModel({
    required int xp,
    required int stars,
    @Default(0) int lives,
  }) = _RewardsModel;

  factory RewardsModel.fromJson(Map<String, dynamic> json) =>
      _$RewardsModelFromJson(json);
}

/// Converts "BST" -> LevelTopic.bst (case-insensitive).
LevelTopic _topicFromJson(String value) {
  switch (value.toUpperCase()) {
    case 'HEAPS':
      return LevelTopic.heaps;
    case 'LISTS':
      return LevelTopic.lists;
    case 'BST':
      return LevelTopic.bst;
    case 'MIXED':
      return LevelTopic.mixed;
    default:
      throw FormatException('Unknown topic: $value');
  }
}

/// Converts LevelTopic.bst -> "BST"
String _topicToJson(LevelTopic topic) {
  switch (topic) {
    case LevelTopic.heaps:
      return 'HEAPS';
    case LevelTopic.lists:
      return 'LISTS';
    case LevelTopic.bst:
      return 'BST';
    case LevelTopic.mixed:
      return 'MIXED';
  }
}
