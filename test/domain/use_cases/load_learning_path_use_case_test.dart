import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/learning_path_syllabus.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';
import 'package:algoquest/domain/use_cases/load_learning_path_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContentRepository implements ContentRepository {
  final LearningPathSyllabus syllabus;
  final Map<String, LevelSyllabus> levels;

  const FakeContentRepository({required this.syllabus, required this.levels});

  @override
  Future<LearningPathSyllabus> getSyllabus() async => syllabus;

  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) async {
    final level = levels[levelId];
    if (level == null) throw StateError('Missing level: $levelId');
    return level;
  }

  @override
  Future<ChallengeSpec> getChallenge(String challengeId) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getNextLevelId(String currentLevelId) {
    throw UnimplementedError();
  }
}

class FakeUserRepository implements UserRepository {
  UserProgress? progress;

  @override
  Future<UserProgress?> fetchUserProgress(String userId) async => progress;

  @override
  Future<void> updateUserProgress(UserProgress userProgress) async {
    progress = userProgress;
  }
}

void main() {
  const syllabus = LearningPathSyllabus(
    title: 'AlgoQuest',
    phases: [
      LearningPathSyllabusPhase(
        id: 'phase_heaps',
        title: 'Heaps',
        levels: [
          LearningPathSyllabusLevelRef(id: 'level_heap_intro'),
          LearningPathSyllabusLevelRef(id: 'level_heap_advanced'),
        ],
      ),
      LearningPathSyllabusPhase(
        id: 'phase_trees',
        title: 'Árboles',
        levels: [LearningPathSyllabusLevelRef(id: 'level_bst_intro')],
      ),
    ],
  );

  const levels = {
    'level_heap_intro': LevelSyllabus(
      id: 'level_heap_intro',
      title: 'Introducción a Heaps',
      subtitle: 'Repara heaps usando intercambios',
      topic: LevelTopic.heaps,
      challenges: ['heap_intro'],
      rewards: LevelRewards(xp: 100, stars: 3),
    ),
    'level_heap_advanced': LevelSyllabus(
      id: 'level_heap_advanced',
      title: 'Heaps avanzados',
      subtitle: 'Retos avanzados de heaps',
      topic: LevelTopic.heaps,
      challenges: ['heap_advanced'],
      rewards: LevelRewards(xp: 150, stars: 3),
    ),
    'level_bst_intro': LevelSyllabus(
      id: 'level_bst_intro',
      title: 'BST básico',
      subtitle: 'Valida árboles BST',
      topic: LevelTopic.bst,
      challenges: ['bst_intro'],
      rewards: LevelRewards(xp: 120, stars: 3),
    ),
  };

  test(
    'loads phases and unlocks only the first level without progress',
    () async {
      final useCase = LoadLearningPathUseCase(
        contentRepository: const FakeContentRepository(
          syllabus: syllabus,
          levels: levels,
        ),
        userRepository: FakeUserRepository(),
      );

      final learningPath = await useCase('user_1');
      final pathLevels = [
        for (final phase in learningPath.phases) ...phase.levels,
      ];

      expect(learningPath.title, 'AlgoQuest');
      expect(learningPath.phases.length, 2);
      expect(pathLevels.map((level) => level.id), [
        'level_heap_intro',
        'level_heap_advanced',
        'level_bst_intro',
      ]);
      expect(pathLevels.map((level) => level.locked), [false, true, true]);
    },
  );

  test('unlocks levels present in user progress', () async {
    final userRepository = FakeUserRepository()
      ..progress = const UserProgress(
        userId: 'user_1',
        level: 2,
        experiencePoints: 100,
        livesRemaining: 5,
        unlockedLevels: {'level_heap_intro', 'level_heap_advanced'},
        completedLevels: {'level_heap_intro'},
        currentLevelId: 'level_heap_advanced',
      );

    final useCase = LoadLearningPathUseCase(
      contentRepository: const FakeContentRepository(
        syllabus: syllabus,
        levels: levels,
      ),
      userRepository: userRepository,
    );

    final learningPath = await useCase('user_1');
    final pathLevels = [
      for (final phase in learningPath.phases) ...phase.levels,
    ];

    expect(pathLevels.map((level) => level.locked), [false, false, true]);
    expect(pathLevels.map((level) => level.completed), [true, false, false]);
    expect(learningPath.progress, userRepository.progress);
  });
}
