import 'package:algoquest/domain/entities/level_syllabus.dart';

class LearningPathPhaseItem {
  final String id;
  final String title;
  final List<LearningPathLevelItem> levels;

  const LearningPathPhaseItem({
    required this.id,
    required this.title,
    required this.levels,
  });
}

class LearningPathLevelItem {
  final String id;
  final String title;
  final String subtitle;
  final LevelTopic topic;
  final bool locked;

  const LearningPathLevelItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.locked,
  });

  factory LearningPathLevelItem.fromJson(
    Map<String, dynamic> json, {
    required bool locked,
  }) {
    return LearningPathLevelItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      topic: _topicFromJson(json['topic'] as String),
      locked: locked,
    );
  }

  static LevelTopic _topicFromJson(String value) {
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
        throw FormatException('Unknown level topic: $value');
    }
  }
}

enum LearningPathStatus { idle, loading, loaded, failed }

class LearningPathState {
  final LearningPathStatus status;
  final String? title;
  final List<LearningPathPhaseItem> phases;
  final String? errorMessage;

  const LearningPathState({
    required this.status,
    required this.title,
    required this.phases,
    required this.errorMessage,
  });

  const LearningPathState.initial()
    : status = LearningPathStatus.idle,
      title = null,
      phases = const [],
      errorMessage = null;

  LearningPathState copyWith({
    LearningPathStatus? status,
    String? title,
    List<LearningPathPhaseItem>? phases,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LearningPathState(
      status: status ?? this.status,
      title: title ?? this.title,
      phases: phases ?? this.phases,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
