import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/user_progress.dart';

class LearningPath {
  final String title;
  final List<LearningPathPhase> phases;
  final UserProgress? progress;

  const LearningPath({
    required this.title,
    required this.phases,
    required this.progress,
  });
}

class LearningPathPhase {
  final String id;
  final String title;
  final List<LearningPathLevel> levels;

  const LearningPathPhase({
    required this.id,
    required this.title,
    required this.levels,
  });
}

class LearningPathLevel {
  final String id;
  final String title;
  final String subtitle;
  final LevelTopic topic;
  final bool locked;

  const LearningPathLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.locked,
  });
}
