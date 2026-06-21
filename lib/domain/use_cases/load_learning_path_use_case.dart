import 'package:algoquest/domain/entities/learning_path.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';

class LoadLearningPathUseCase {
  final ContentRepository _contentRepository;
  final UserRepository _userRepository;

  const LoadLearningPathUseCase({
    required ContentRepository contentRepository,
    required UserRepository userRepository,
  }) : _contentRepository = contentRepository,
       _userRepository = userRepository;

  Future<LearningPath> call(String userId) async {
    final syllabus = await _contentRepository.getSyllabus();
    final progress = await _userRepository.fetchUserProgress(userId);
    final unlockedLevels = progress?.unlockedLevels ?? const <String>{};
    final completedLevels = progress?.completedLevels ?? const <String>{};

    var globalLevelIndex = 0;
    final phases = <LearningPathPhase>[];

    for (final phaseRef in syllabus.phases) {
      final levels = <LearningPathLevel>[];

      for (final levelRef in phaseRef.levels) {
        final level = await _contentRepository.getLevelSyllabus(levelRef.id);
        final isFirstLevel = globalLevelIndex == 0;
        final locked = !isFirstLevel && !unlockedLevels.contains(level.id);

        levels.add(
          LearningPathLevel(
            id: level.id,
            title: level.title,
            subtitle: level.subtitle,
            topic: level.topic,
            locked: locked,
            completed: completedLevels.contains(level.id),
          ),
        );

        globalLevelIndex++;
      }

      phases.add(
        LearningPathPhase(
          id: phaseRef.id,
          title: phaseRef.title,
          levels: levels,
        ),
      );
    }

    return LearningPath(
      title: syllabus.title,
      phases: phases,
      progress: progress,
    );
  }
}
