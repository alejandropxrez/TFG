import 'package:algoquest/application/app_providers.dart';
import 'package:algoquest/application/learning_path_provider.dart';
import 'package:algoquest/application/learning_path_state.dart';
import 'package:algoquest/core/composition/use_cases.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';
import 'package:algoquest/domain/usecases/check_solution_use_case.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/usecases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/usecases/load_user_progress_use_case.dart';
import 'package:algoquest/domain/usecases/manage_progress_use_case.dart';
import 'package:algoquest/domain/usecases/save_progress_use_case.dart';
import 'package:algoquest/domain/usecases/start_challenge_session_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContentRepository implements ContentRepository {
  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) {
    throw UnimplementedError();
  }

  @override
  Future<ChallengeSpec> getChallenge(String challengeId) {
    throw UnimplementedError();
  }
}

class FakeUserRepository implements UserRepository {
  UserProgress? progress;

  @override
  Future<UserProgress?> fetchUserProgress(String userId) async {
    return progress;
  }

  @override
  Future<void> updateUserProgress(UserProgress userProgress) async {
    progress = userProgress;
  }
}

void main() {
  late ProviderContainer container;
  late FakeContentRepository contentRepository;
  late FakeUserRepository userRepository;
  late UseCases useCases;

  const syllabusJson = '''
  {
    "version": "1.0",
    "title": "AlgoQuest",
    "phases": [
      {
        "id": "phase_heaps",
        "title": "Heaps",
        "levels": [
          {
            "id": "level_heap_intro",
            "title": "Introducción a Heaps",
            "topic": "HEAPS",
            "subtitle": "Repara heaps usando intercambios",
            "challenges": ["heap_repair_intro"],
            "rewards": { "xp": 100, "stars": 3 }
          },
          {
            "id": "level_heap_advanced",
            "title": "Heaps avanzados",
            "topic": "HEAPS",
            "subtitle": "Retos avanzados de heaps",
            "challenges": ["heap_advanced_1"],
            "rewards": { "xp": 150, "stars": 3 }
          }
        ]
      },
      {
        "id": "phase_trees",
        "title": "Árboles",
        "levels": [
          {
            "id": "level_bst_intro",
            "title": "BST básico",
            "topic": "BST",
            "subtitle": "Valida árboles BST",
            "challenges": ["bst_intro"],
            "rewards": { "xp": 120, "stars": 3 }
          }
        ]
      }
    ]
  }
  ''';

  setUp(() {
    contentRepository = FakeContentRepository();
    userRepository = FakeUserRepository();

    useCases = UseCases(
      getLevelSyllabus: GetLevelSyllabusUseCase(contentRepository),
      loadChallengeSpec: LoadChallengeSpecUseCase(contentRepository),
      startChallengeSession: StartChallengeSessionUseCase(contentRepository),
      executeMove: const ExecuteMoveUseCase(),
      checkSolution: const CheckSolutionUseCase(),
      saveProgress: SaveProgressUseCase(userRepository),
      manageProgress: const ManageProgressUseCase(),
      loadUserProgress: LoadUserProgressUseCase(userRepository),
    );

    container = ProviderContainer(
      overrides: [
        useCasesProvider.overrideWithValue(useCases),
        currentUserIdProvider.overrideWithValue('user_1'),
        syllabusJsonLoaderProvider.overrideWithValue(() async => syllabusJson),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads phases and levels from syllabus JSON', () async {
    final notifier = container.read(learningPathProvider.notifier);

    await notifier.load();

    final state = container.read(learningPathProvider);

    expect(state.status, LearningPathStatus.loaded);
    expect(state.title, 'AlgoQuest');
    expect(state.phases.length, 2);

    expect(state.phases[0].id, 'phase_heaps');
    expect(state.phases[0].title, 'Heaps');
    expect(state.phases[0].levels.length, 2);

    expect(state.phases[0].levels[0].id, 'level_heap_intro');
    expect(state.phases[0].levels[0].title, 'Introducción a Heaps');
    expect(state.phases[0].levels[0].topic, LevelTopic.heaps);

    expect(state.phases[1].id, 'phase_trees');
    expect(state.phases[1].levels.single.id, 'level_bst_intro');
    expect(state.phases[1].levels.single.topic, LevelTopic.bst);
  });

  test('unlocks first level when user has no progress', () async {
    final notifier = container.read(learningPathProvider.notifier);

    await notifier.load();

    final state = container.read(learningPathProvider);
    final levels = [for (final phase in state.phases) ...phase.levels];

    expect(levels[0].id, 'level_heap_intro');
    expect(levels[0].locked, isFalse);

    expect(levels[1].id, 'level_heap_advanced');
    expect(levels[1].locked, isTrue);

    expect(levels[2].id, 'level_bst_intro');
    expect(levels[2].locked, isTrue);
  });

  test('unlocks levels present in user progress', () async {
    userRepository.progress = UserProgress(
      userId: 'user_1',
      level: 2,
      experiencePoints: 100,
      livesRemaining: 5,
      unlockedLevels: {'level_heap_intro', 'level_heap_advanced'},
      currentLevelId: 'level_heap_advanced',
    );

    final notifier = container.read(learningPathProvider.notifier);

    await notifier.load();

    final state = container.read(learningPathProvider);
    final levels = [for (final phase in state.phases) ...phase.levels];

    expect(levels[0].locked, isFalse);
    expect(levels[1].locked, isFalse);
    expect(levels[2].locked, isTrue);
  });

  test('sets failed status when syllabus JSON is invalid', () async {
    final failingContainer = ProviderContainer(
      overrides: [
        useCasesProvider.overrideWithValue(useCases),
        currentUserIdProvider.overrideWithValue('user_1'),
        syllabusJsonLoaderProvider.overrideWithValue(() async => '{ invalid'),
      ],
    );

    addTearDown(failingContainer.dispose);

    final notifier = failingContainer.read(learningPathProvider.notifier);

    await notifier.load();

    final state = failingContainer.read(learningPathProvider);

    expect(state.status, LearningPathStatus.failed);
    expect(state.errorMessage, isNotNull);
  });
}
