import 'package:algoquest/domain/entities/learning_path.dart';
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

  factory LearningPathPhaseItem.fromDomain(LearningPathPhase phase) {
    return LearningPathPhaseItem(
      id: phase.id,
      title: phase.title,
      levels: phase.levels.map(LearningPathLevelItem.fromDomain).toList(),
    );
  }
}

class LearningPathLevelItem {
  final String id;
  final String title;
  final String subtitle;
  final LevelTopic topic;
  final bool locked;
  final bool completed;

  const LearningPathLevelItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.locked,
    required this.completed,
  });

  factory LearningPathLevelItem.fromDomain(LearningPathLevel level) {
    return LearningPathLevelItem(
      id: level.id,
      title: level.title,
      subtitle: level.subtitle,
      topic: level.topic,
      locked: level.locked,
      completed: level.completed,
    );
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

  factory LearningPathState.loaded(LearningPath learningPath) {
    return LearningPathState(
      status: LearningPathStatus.loaded,
      title: learningPath.title,
      phases: learningPath.phases
          .map(LearningPathPhaseItem.fromDomain)
          .toList(),
      errorMessage: null,
    );
  }

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
