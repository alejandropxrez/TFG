import 'package:algoquest/domain/use_cases/complete_level_use_case.dart';
import 'package:algoquest/domain/use_cases/restart_challenge_session_use_case.dart';
import 'package:algoquest/domain/use_cases/reveal_challenge_answer_use_case.dart';
import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/application_state/learning_path_provider.dart';
import 'package:algoquest/presentation/application_state/learning_path_state.dart';
import 'package:algoquest/data/core/composition/use_cases.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/learning_path_syllabus.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';
import 'package:algoquest/domain/use_cases/check_challenge_use_case.dart';
import 'package:algoquest/domain/use_cases/check_solution_use_case.dart';
import 'package:algoquest/domain/use_cases/consume_attempt_use_case.dart';
import 'package:algoquest/domain/use_cases/execute_move_use_case.dart';
import 'package:algoquest/domain/use_cases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/use_cases/get_next_level_id_use_case.dart';
import 'package:algoquest/domain/use_cases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/use_cases/load_learning_path_use_case.dart';
import 'package:algoquest/domain/use_cases/load_user_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/manage_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/redo_move_use_case.dart';
import 'package:algoquest/domain/use_cases/save_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/start_challenge_session_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_categorization_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_identify_target_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_quiz_answer_use_case.dart';
import 'package:algoquest/domain/use_cases/undo_move_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContentRepository implements ContentRepository {
  LearningPathSyllabus? syllabus;
  final Map<String, LevelSyllabus> levels = {};
  Object? syllabusError;

  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) async {
    final level = levels[levelId];
    if (level == null) throw StateError('Missing test level for $levelId');
    return level;
  }

  @override
  Future<LearningPathSyllabus> getSyllabus() async {
    final error = syllabusError;
    if (error != null) throw error;

    final value = syllabus;
    if (value == null) throw StateError('Missing test syllabus');
    return value;
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

  setUp(() {
    contentRepository = FakeContentRepository();
    userRepository = FakeUserRepository();

    contentRepository.syllabus = const LearningPathSyllabus(
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

    contentRepository.levels.addAll({
      'level_heap_intro': const LevelSyllabus(
        id: 'level_heap_intro',
        title: 'Introducción a Heaps',
        subtitle: 'Repara heaps usando intercambios',
        topic: LevelTopic.heaps,
        challenges: ['heap_repair_intro'],
        rewards: LevelRewards(xp: 100, stars: 3, lives: 1),
      ),
      'level_heap_advanced': const LevelSyllabus(
        id: 'level_heap_advanced',
        title: 'Heaps avanzados',
        subtitle: 'Retos avanzados de heaps',
        topic: LevelTopic.heaps,
        challenges: ['heap_advanced_1'],
        rewards: LevelRewards(xp: 150, stars: 3, lives: 1),
      ),
      'level_bst_intro': const LevelSyllabus(
        id: 'level_bst_intro',
        title: 'BST básico',
        subtitle: 'Valida árboles BST',
        topic: LevelTopic.bst,
        challenges: ['bst_intro'],
        rewards: LevelRewards(xp: 120, stars: 3, lives: 1),
      ),
    });

    final loadUserProgress = LoadUserProgressUseCase(userRepository);
    final saveProgress = SaveProgressUseCase(userRepository);
    final getNextLevelId = GetNextLevelIdUseCase(contentRepository);
    final manageProgress = const ManageProgressUseCase();

    useCases = UseCases(
      getLevelSyllabus: GetLevelSyllabusUseCase(contentRepository),
      loadChallengeSpec: LoadChallengeSpecUseCase(contentRepository),
      startChallengeSession: StartChallengeSessionUseCase(contentRepository),
      executeMove: const ExecuteMoveUseCase(),
      checkSolution: const CheckSolutionUseCase(),
      saveProgress: saveProgress,
      manageProgress: manageProgress,
      loadUserProgress: loadUserProgress,
      loadLearningPath: LoadLearningPathUseCase(
        contentRepository: contentRepository,
        userRepository: userRepository,
      ),
      undoMove: const UndoMoveUseCase(),
      redoMove: const RedoMoveUseCase(),
      consumeAttempt: const ConsumeAttemptUseCase(),
      checkChallenge: const CheckChallengeUseCase(),
      submitQuizAnswer: const SubmitQuizAnswerUseCase(),
      submitIdentifyTarget: const SubmitIdentifyTargetUseCase(),
      submitCategorization: const SubmitCategorizationUseCase(),
      getNextLevelId: getNextLevelId,
      revealChallengeAnswer: RevealChallengeAnswerUseCase(),
      restartChallengeSession: RestartChallengeSessionUseCase(),
      completeLevelProgress: CompleteLevelProgressUseCase(
        loadUserProgress: loadUserProgress.call,
        saveProgress: saveProgress.call,
        getNextLevelId: getNextLevelId.call,
        manageProgress: manageProgress,
      ),
    );

    container = ProviderContainer(
      overrides: [
        useCasesProvider.overrideWithValue(useCases),
        currentUserIdProvider.overrideWithValue('user_1'),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads phases and levels from syllabus JSON', () async {
    final state = await container.read(learningPathProvider.future);

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
    final state = await container.read(learningPathProvider.future);
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

    final state = await container.read(learningPathProvider.future);
    final levels = [for (final phase in state.phases) ...phase.levels];

    expect(levels[0].locked, isFalse);
    expect(levels[1].locked, isFalse);
    expect(levels[2].locked, isTrue);
  });

  test('sets failed status when learning path cannot be loaded', () async {
    contentRepository.syllabusError = const FormatException('invalid syllabus');

    final failingContainer = ProviderContainer(
      overrides: [
        useCasesProvider.overrideWithValue(useCases),
        currentUserIdProvider.overrideWithValue('user_1'),
      ],
    );

    addTearDown(failingContainer.dispose);

    await expectLater(
      failingContainer.read(learningPathProvider.future),
      throwsA(isA<Object>()),
    );

    expect(failingContainer.read(learningPathProvider).hasError, isTrue);
  });
}
