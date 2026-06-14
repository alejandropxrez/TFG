import 'package:algoquest/application/app_providers.dart';
import 'package:algoquest/data/mappers/level_syllabus_mapper.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart' as model;
import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/use_cases/check_challenge_use_case.dart';
import 'package:algoquest/domain/use_cases/consume_attempt_use_case.dart';
import 'package:algoquest/domain/use_cases/get_next_level_id_use_case.dart';
import 'package:algoquest/domain/use_cases/load_user_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/redo_move_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_categorization_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_identify_target_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_quiz_answer_use_case.dart';
import 'package:algoquest/domain/use_cases/undo_move_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/application/level_state.dart';
import 'package:algoquest/application/level_state_provider.dart';

import 'package:algoquest/core/composition/use_cases.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/user_progress.dart';

import 'package:algoquest/domain/enums/structure_type.dart';

import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';

import 'package:algoquest/domain/strategies/validation_strategy.dart';

import 'package:algoquest/domain/use_cases/check_solution_use_case.dart';
import 'package:algoquest/domain/use_cases/execute_move_use_case.dart';
import 'package:algoquest/domain/use_cases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/use_cases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/use_cases/manage_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/save_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/start_challenge_session_use_case.dart';

class AlwaysTrueValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => true;
}

class AlwaysFalseValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => false;
}

class FakeContentRepository implements ContentRepository {
  final Map<String, LevelSyllabus> syllabuses = {};
  final Map<String, ChallengeSpec> specs = {};
  final Map<String, String?> nextLevelIds = {};

  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) async {
    final syllabus = syllabuses[levelId];

    if (syllabus == null) {
      throw Exception('Missing syllabus: $levelId');
    }

    return syllabus;
  }

  @override
  Future<ChallengeSpec> getChallenge(String challengeId) async {
    final spec = specs[challengeId];

    if (spec == null) {
      throw Exception('Missing challenge spec: $challengeId');
    }

    return spec;
  }

  @override
  Future<String?> getNextLevelId(String currentLevelId) async {
    if (!nextLevelIds.containsKey(currentLevelId)) {
      throw StateError('Missing next level mapping for $currentLevelId');
    }

    return nextLevelIds[currentLevelId];
  }
}

class FakeUserRepository implements UserRepository {
  UserProgress? savedProgress;

  @override
  Future<UserProgress?> fetchUserProgress(String userId) async {
    return savedProgress;
  }

  @override
  Future<void> updateUserProgress(UserProgress userProgress) async {
    savedProgress = userProgress;
  }
}

void main() {
  late ProviderContainer container;
  late FakeContentRepository contentRepository;
  late FakeUserRepository userRepository;
  late UseCases useCases;

  const testSyllabusJson = '''
  {
    "version": "1.0",
    "title": "AlgoQuest",
    "phases": [
      {
        "id": "phase_test",
        "title": "Test Phase",
        "levels": [
          {
            "id": "single_challenge_level",
            "title": "Single Challenge Level",
            "topic": "HEAPS",
            "subtitle": "Test level",
            "challenges": ["challenge_1"],
            "rewards": {
              "xp": 100,
              "stars": 3
            }
          },
          {
            "id": "next_level",
            "title": "Next Level",
            "topic": "HEAPS",
            "subtitle": "Next test level",
            "challenges": ["challenge_2"],
            "rewards": {
              "xp": 150,
              "stars": 3
            }
          }
        ]
      }
    ]
  }
  ''';

  LevelSyllabus buildSyllabus({
    String id = 'level_heap_intro',
    List<String> challenges = const ['challenge_1', 'challenge_2'],
  }) {
    return LevelSyllabus(
      id: id,
      title: 'Heap Intro',
      topic: LevelTopic.heaps,
      challenges: challenges,
      rewards: const LevelRewards(xp: 100, stars: 3),
    );
  }

  ChallengeSpec buildChallengeSpec({
    required String id,
    required String title,
  }) {
    return ChallengeSpec(
      id: id,
      title: title,
      instruction: 'Swap nodes to repair the heap',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: AlwaysTrueValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.swap,
          connectionType: ConnectionType.explicit,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [
            ChallengeNodeSpec(id: 'n1', value: 3),
            ChallengeNodeSpec(id: 'n2', value: 10),
          ],
          edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
          slots: [],
          inventory: [],
        ),
      ),
    );
  }

  ChallengeSpec buildAttemptsSpec({
    required ValidationStrategy validationStrategy,
    List<ChallengeConstraint> constraints = const [],
  }) {
    return ChallengeSpec(
      id: 'challenge_attempts',
      title: 'Attempts Challenge',
      instruction: 'Try it',
      theoryRef: null,
      constraints: constraints,
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: validationStrategy,
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.swap,
          connectionType: ConnectionType.explicit,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [
            ChallengeNodeSpec(id: 'n1', value: 3),
            ChallengeNodeSpec(id: 'n2', value: 10),
          ],
          edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
          slots: [],
          inventory: [],
        ),
      ),
    );
  }

  ChallengeSpec buildMultipleChoiceQuizSpec({
    List<ChallengeConstraint> constraints = const [],
  }) {
    return ChallengeSpec(
      id: 'quiz_heap_properties_multiple',
      title: 'Propiedades de Max Heap',
      instruction: 'Selecciona todas las afirmaciones correctas',
      theoryRef: 'heap_intro',
      constraints: constraints,
      content: QuizChallengeContent(
        quizSpec: QuizSpec(
          question: '¿Qué afirmaciones son verdaderas sobre un max-heap?',
          options: [
            QuizOption(
              id: 'a',
              text: 'Cada padre es mayor o igual que sus hijos.',
            ),
            QuizOption(id: 'b', text: 'El valor máximo está en la raíz.'),
            QuizOption(
              id: 'c',
              text: 'Los valores deben estar ordenados en inorden.',
            ),
          ],
          correctOptionIds: {'a', 'b'},
          allowMultiple: true,
        ),
      ),
    );
  }

  ChallengeSpec buildIdentifyNodeSpec({
    List<ChallengeConstraint> constraints = const [],
  }) {
    return ChallengeSpec(
      id: 'identify_heap_wrong_node',
      title: 'Nodo incorrecto',
      instruction: 'Toca el nodo que rompe la propiedad de max-heap',
      theoryRef: 'heap_property',
      constraints: constraints,
      content: IdentifyTargetChallengeContent(
        identifySpec: IdentifyTargetSpec(
          prompt: '¿Qué nodo rompe la propiedad de max-heap?',
          targetType: IdentifyTargetType.node,
          correctTargetIds: {'n2'},
        ),
        visualStructure: StructureChallengeContent(
          engineConfig: ChallengeEngineConfig(
            structureType: StructureType.heap,
            validationStrategy: AlwaysFalseValidationStrategy(),
            layoutStrategy: LayoutStrategyType.pyramid,
            interactionMode: InteractionModeType.swap,
            connectionType: ConnectionType.explicit,
          ),
          initialState: const ChallengeInitialStateSpec(
            nodes: [
              ChallengeNodeSpec(id: 'n1', value: 10),
              ChallengeNodeSpec(id: 'n2', value: 15),
              ChallengeNodeSpec(id: 'n3', value: 7),
            ],
            edges: [
              ChallengeEdgeSpec(source: 'n1', target: 'n2'),
              ChallengeEdgeSpec(source: 'n1', target: 'n3'),
            ],
            slots: [],
            inventory: [],
          ),
        ),
      ),
    );
  }

  setUp(() {
    contentRepository = FakeContentRepository();
    userRepository = FakeUserRepository();

    contentRepository.nextLevelIds.addAll({
      'level_heap_intro': 'single_challenge_level',
      'single_challenge_level': 'next_level',
      'next_level': null,
      'level_attempts': null,
      'level_tutorial': null,
      'level_multiple_quiz': null,
      'level_identify': null,
    });

    contentRepository.syllabuses['level_heap_intro'] = buildSyllabus(
      id: 'level_heap_intro',
    );

    contentRepository.syllabuses['single_challenge_level'] = buildSyllabus(
      id: 'single_challenge_level',
      challenges: const ['challenge_1'],
    );

    contentRepository.specs['challenge_1'] = buildChallengeSpec(
      id: 'challenge_1',
      title: 'Heap repair 1',
    );

    contentRepository.specs['challenge_2'] = buildChallengeSpec(
      id: 'challenge_2',
      title: 'Heap repair 2',
    );

    useCases = UseCases(
      getLevelSyllabus: GetLevelSyllabusUseCase(contentRepository),
      loadChallengeSpec: LoadChallengeSpecUseCase(contentRepository),
      startChallengeSession: StartChallengeSessionUseCase(contentRepository),
      executeMove: const ExecuteMoveUseCase(),
      checkSolution: const CheckSolutionUseCase(),
      saveProgress: SaveProgressUseCase(userRepository),
      manageProgress: const ManageProgressUseCase(),
      loadUserProgress: LoadUserProgressUseCase(userRepository),
      undoMove: const UndoMoveUseCase(),
      redoMove: const RedoMoveUseCase(),
      consumeAttempt: const ConsumeAttemptUseCase(),
      checkChallenge: const CheckChallengeUseCase(),
      submitQuizAnswer: const SubmitQuizAnswerUseCase(),
      submitIdentifyTarget: const SubmitIdentifyTargetUseCase(),
      submitCategorization: const SubmitCategorizationUseCase(),
      getNextLevelId: GetNextLevelIdUseCase(contentRepository),
    );

    container = ProviderContainer(
      overrides: [
        useCasesProvider.overrideWithValue(useCases),
        currentUserIdProvider.overrideWithValue('user_1'),
        syllabusJsonLoaderProvider.overrideWithValue(
          () async => testSyllabusJson,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is idle and empty', () {
    final state = container.read(levelStateProvider);

    expect(state.status, LevelFlowStatus.idle);
    expect(state.syllabus, isNull);
    expect(state.sessionManager, isNull);
    expect(state.currentChallengeSpec, isNull);
    expect(state.currentSession, isNull);
    expect(state.currentChallengeIndex, 0);
    expect(state.totalChallenges, 0);
    expect(state.currentChallengeId, isNull);
    expect(state.errorMessage, isNull);
  });

  test('loadLevel loads syllabus and creates SessionManager', () async {
    final notifier = container.read(levelStateProvider.notifier);

    await notifier.loadLevel('level_heap_intro');

    final state = container.read(levelStateProvider);

    expect(state.status, LevelFlowStatus.idle);
    expect(state.syllabus, isNotNull);
    expect(state.syllabus!.id, 'level_heap_intro');
    expect(state.syllabus!.title, 'Heap Intro');

    expect(state.sessionManager, isNotNull);
    expect(state.currentChallengeIndex, 0);
    expect(state.totalChallenges, 2);
    expect(state.currentChallengeId, 'challenge_1');
    expect(state.errorMessage, isNull);
  });

  test('startCurrentChallenge creates session for current challenge', () async {
    final notifier = container.read(levelStateProvider.notifier);

    await notifier.loadLevel('level_heap_intro');

    await notifier.startCurrentChallenge(
      userId: 'user_1',
      sessionId: 'session_1',
    );

    final state = container.read(levelStateProvider);

    expect(state.status, LevelFlowStatus.playing);
    expect(state.currentChallengeSpec, isNotNull);
    expect(state.currentChallengeSpec!.id, 'challenge_1');
    expect(state.currentChallengeSpec!.title, 'Heap repair 1');

    expect(state.currentSession, isNotNull);
    expect(state.currentSession!.sessionId, 'session_1');
    expect(state.currentSession!.userId, 'user_1');

    expect(
      state.currentSession!.structureRuntimeState.structure.nodes['n1']!.value,
      3,
    );
    expect(
      state.currentSession!.structureRuntimeState.structure.nodes['n2']!.value,
      10,
    );

    expect(state.currentChallengeIndex, 0);
    expect(state.totalChallenges, 2);
    expect(state.currentChallengeId, 'challenge_1');
    expect(state.errorMessage, isNull);
  });

  test('startChallenge can create session for explicit challenge id', () async {
    final notifier = container.read(levelStateProvider.notifier);

    await notifier.startChallenge(
      userId: 'user_1',
      challengeId: 'challenge_2',
      sessionId: 'session_2',
    );

    final state = container.read(levelStateProvider);

    expect(state.status, LevelFlowStatus.playing);
    expect(state.currentChallengeSpec, isNotNull);
    expect(state.currentChallengeSpec!.id, 'challenge_2');
    expect(state.currentChallengeSpec!.title, 'Heap repair 2');

    expect(state.currentSession, isNotNull);
    expect(state.currentSession!.sessionId, 'session_2');
    expect(state.currentSession!.userId, 'user_1');
  });

  test('executeAction updates current session state', () async {
    final notifier = container.read(levelStateProvider.notifier);

    await notifier.loadLevel('level_heap_intro');

    await notifier.startCurrentChallenge(
      userId: 'user_1',
      sessionId: 'session_1',
    );

    notifier.executeAction(
      const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    final state = container.read(levelStateProvider);
    final session = state.currentSession!;

    expect(state.status, LevelFlowStatus.playing);
    expect(session.structureRuntimeState.movesUsed, 1);
    expect(session.structureRuntimeState.history.length, 1);

    expect(session.structureRuntimeState.structure.nodes['n1']!.value, 10);
    expect(session.structureRuntimeState.structure.nodes['n2']!.value, 3);
  });

  test('checkSolution marks current challenge as solved', () async {
    final notifier = container.read(levelStateProvider.notifier);

    await notifier.loadLevel('level_heap_intro');

    await notifier.startCurrentChallenge(
      userId: 'user_1',
      sessionId: 'session_1',
    );

    final solved = notifier.checkSolution();

    final state = container.read(levelStateProvider);

    expect(solved, isTrue);
    expect(state.status, LevelFlowStatus.challengeSolved);
  });

  test(
    'completeCurrentChallenge starts next challenge when available',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      await notifier.loadLevel('level_heap_intro');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_1',
      );

      await notifier.completeCurrentChallenge(
        userId: 'user_1',
        nextSessionId: 'session_2',
      );

      final state = container.read(levelStateProvider);

      expect(state.status, LevelFlowStatus.playing);
      expect(state.currentChallengeIndex, 1);
      expect(state.totalChallenges, 2);
      expect(state.currentChallengeId, 'challenge_2');

      expect(state.currentChallengeSpec, isNotNull);
      expect(state.currentChallengeSpec!.id, 'challenge_2');
      expect(state.currentChallengeSpec!.title, 'Heap repair 2');

      expect(state.currentSession, isNotNull);
      expect(state.currentSession!.sessionId, 'session_2');
    },
  );

  test(
    'completeCurrentChallenge completes level when no challenges remain',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      await notifier.loadLevel('single_challenge_level');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_1',
      );

      await notifier.completeCurrentChallenge(
        userId: 'user_1',
        nextSessionId: 'unused_session',
      );

      final state = container.read(levelStateProvider);

      expect(state.status, LevelFlowStatus.completed);
      expect(state.sessionManager, isNotNull);
      expect(state.isLevelCompleted, isTrue);
      expect(state.currentChallengeId, isNull);
      expect(state.currentChallengeSpec, isNull);
      expect(state.currentSession, isNull);
    },
  );

  test('loadLevel stores error when syllabus does not exist', () async {
    final notifier = container.read(levelStateProvider.notifier);

    await notifier.loadLevel('missing_level');

    final state = container.read(levelStateProvider);

    expect(state.status, LevelFlowStatus.failed);
    expect(state.errorMessage, isNotNull);
  });

  test('startCurrentChallenge fails when no level is loaded', () async {
    final notifier = container.read(levelStateProvider.notifier);

    await notifier.startCurrentChallenge(
      userId: 'user_1',
      sessionId: 'session_1',
    );

    final state = container.read(levelStateProvider);

    expect(state.status, LevelFlowStatus.failed);
    expect(state.errorMessage, isNotNull);
    expect(state.currentSession, isNull);
  });

  test(
    'completeCurrentChallenge applies rewards and unlocks next level when level is completed',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      await notifier.loadLevel('single_challenge_level');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_1',
      );

      await notifier.completeCurrentChallenge(
        userId: 'user_1',
        nextSessionId: 'unused_session',
      );

      final state = container.read(levelStateProvider);

      expect(state.status, LevelFlowStatus.completed);
      expect(state.isLevelCompleted, isTrue);

      expect(userRepository.savedProgress, isNotNull);
      expect(userRepository.savedProgress!.userId, 'user_1');
      expect(userRepository.savedProgress!.experiencePoints, 100);

      expect(
        userRepository.savedProgress!.unlockedLevels,
        contains('single_challenge_level'),
      );

      expect(
        userRepository.savedProgress!.unlockedLevels,
        contains('next_level'),
      );

      expect(userRepository.savedProgress!.currentLevelId, 'next_level');
    },
  );

  test('checkSolution consumes one attempt when solution is wrong', () async {
    final notifier = container.read(levelStateProvider.notifier);

    contentRepository.syllabuses['level_attempts'] = LevelSyllabus(
      id: 'level_attempts',
      title: 'Attempts Level',
      topic: LevelTopic.heaps,
      challenges: const ['challenge_attempts'],
      rewards: const LevelRewards(xp: 100, stars: 3),
    );

    contentRepository.specs['challenge_attempts'] = buildAttemptsSpec(
      validationStrategy: AlwaysFalseValidationStrategy(),
      constraints: const [
        MaxAttemptsConstraint(3),
        LivesConsumedOnFailConstraint(1),
      ],
    );

    await notifier.loadLevel('level_attempts');

    await notifier.startCurrentChallenge(
      userId: 'user_1',
      sessionId: 'session_1',
    );

    final solved = notifier.checkSolution();

    final state = container.read(levelStateProvider);

    expect(solved, isFalse);
    expect(state.status, LevelFlowStatus.playing);
    expect(state.currentSession!.attemptsRemaining, 2);
    expect(state.currentSession!.status, SessionStatus.inProgress);
  });

  test(
    'checkSolution marks challenge as failed when attempts reach zero',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_attempts'] = LevelSyllabus(
        id: 'level_attempts',
        title: 'Attempts Level',
        topic: LevelTopic.heaps,
        challenges: const ['challenge_attempts'],
        rewards: const LevelRewards(xp: 100, stars: 3),
      );

      contentRepository.specs['challenge_attempts'] = buildAttemptsSpec(
        validationStrategy: AlwaysFalseValidationStrategy(),
        constraints: const [
          MaxAttemptsConstraint(1),
          LivesConsumedOnFailConstraint(1),
        ],
      );

      await notifier.loadLevel('level_attempts');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_1',
      );

      final solved = notifier.checkSolution();

      final state = container.read(levelStateProvider);

      expect(solved, isFalse);
      expect(state.status, LevelFlowStatus.challengeFailed);
      expect(state.currentSession!.attemptsRemaining, 0);
      expect(state.currentSession!.status, SessionStatus.failed);
      expect(state.errorMessage, isNotNull);
    },
  );

  test(
    'checkSolution does not consume attempts when solution is correct',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_attempts'] = LevelSyllabus(
        id: 'level_attempts',
        title: 'Attempts Level',
        topic: LevelTopic.heaps,
        challenges: const ['challenge_attempts'],
        rewards: const LevelRewards(xp: 100, stars: 3),
      );

      contentRepository.specs['challenge_attempts'] = buildAttemptsSpec(
        validationStrategy: AlwaysTrueValidationStrategy(),
        constraints: const [
          MaxAttemptsConstraint(3),
          LivesConsumedOnFailConstraint(1),
        ],
      );

      await notifier.loadLevel('level_attempts');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_1',
      );

      final solved = notifier.checkSolution();

      final state = container.read(levelStateProvider);

      expect(solved, isTrue);
      expect(state.status, LevelFlowStatus.challengeSolved);
      expect(state.currentSession!.attemptsRemaining, 3);
      expect(state.currentSession!.status, SessionStatus.completed);
    },
  );

  test(
    'checkSolution consumes one attempt even when livesConsumedOnFail is zero',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_tutorial'] = LevelSyllabus(
        id: 'level_tutorial',
        title: 'Tutorial Level',
        topic: LevelTopic.heaps,
        challenges: const ['challenge_tutorial'],
        rewards: const LevelRewards(xp: 100, stars: 3),
      );

      contentRepository.specs['challenge_tutorial'] = buildAttemptsSpec(
        validationStrategy: AlwaysFalseValidationStrategy(),
        constraints: const [
          MaxAttemptsConstraint(3),
          LivesConsumedOnFailConstraint(0),
        ],
      );

      await notifier.loadLevel('level_tutorial');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_1',
      );

      final solved = notifier.checkSolution();

      final state = container.read(levelStateProvider);

      expect(solved, isFalse);
      expect(state.status, LevelFlowStatus.playing);
      expect(state.currentSession!.attemptsRemaining, 2);
      expect(state.currentSession!.status, SessionStatus.inProgress);
    },
  );

  test(
    'completeCurrentChallenge applies lives reward when level is completed',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      userRepository.savedProgress = const UserProgress(
        userId: 'user_1',
        currentLevelId: 'single_challenge_level',
        unlockedLevels: {'single_challenge_level'},
        experiencePoints: 0,
        level: 1,
        livesRemaining: 2,
      );

      contentRepository.syllabuses['single_challenge_level'] = LevelSyllabus(
        id: 'single_challenge_level',
        title: 'Single Challenge Level',
        topic: LevelTopic.heaps,
        challenges: const ['challenge_attempts'],
        rewards: const LevelRewards(xp: 100, stars: 3, lives: 1),
      );

      contentRepository.specs['challenge_attempts'] = buildAttemptsSpec(
        validationStrategy: AlwaysTrueValidationStrategy(),
        constraints: const [
          MaxAttemptsConstraint(3),
          LivesConsumedOnFailConstraint(1),
        ],
      );

      await notifier.loadLevel('single_challenge_level');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_1',
      );

      final solved = notifier.checkSolution();
      expect(solved, isTrue);

      await notifier.completeCurrentChallenge(
        userId: 'user_1',
        nextSessionId: 'unused_session',
      );

      final state = container.read(levelStateProvider);

      expect(state.status, LevelFlowStatus.completed);
      expect(state.errorMessage, isNull);

      expect(userRepository.savedProgress, isNotNull);
      expect(userRepository.savedProgress!.experiencePoints, 100);
      expect(userRepository.savedProgress!.livesRemaining, 3);

      expect(
        userRepository.savedProgress!.unlockedLevels,
        contains('next_level'),
      );

      expect(userRepository.savedProgress!.currentLevelId, 'next_level');
    },
  );

  test('parses lives reward when present', () {
    final json = {
      'id': 'level_heap_intro',
      'title': 'Heap Intro',
      'topic': 'HEAPS',
      'challenges': ['challenge_1'],
      'rewards': {'xp': 100, 'stars': 3, 'lives': 1},
    };

    final levelModel = model.LevelSyllabusModel.fromJson(json);
    final domain = LevelSyllabusMapper.toDomain(levelModel);

    expect(domain.rewards.xp, 100);
    expect(domain.rewards.stars, 3);
    expect(domain.rewards.lives, 1);
  });

  test('defaults lives reward to zero when omitted', () {
    final json = {
      'id': 'level_heap_intro',
      'title': 'Heap Intro',
      'topic': 'HEAPS',
      'challenges': ['challenge_1'],
      'rewards': {'xp': 100, 'stars': 3},
    };

    final levelModel = model.LevelSyllabusModel.fromJson(json);
    final domain = LevelSyllabusMapper.toDomain(levelModel);

    expect(domain.rewards.xp, 100);
    expect(domain.rewards.stars, 3);
    expect(domain.rewards.lives, 0);
  });

  test(
    'checkSolution marks multiple choice quiz as solved when all correct options are selected',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_multiple_quiz'] = LevelSyllabus(
        id: 'level_multiple_quiz',
        title: 'Multiple Quiz Level',
        topic: LevelTopic.heaps,
        challenges: const ['quiz_heap_properties_multiple'],
        rewards: const LevelRewards(xp: 50, stars: 1),
      );

      contentRepository.specs['quiz_heap_properties_multiple'] =
          buildMultipleChoiceQuizSpec(
            constraints: const [
              MaxAttemptsConstraint(3),
              LivesConsumedOnFailConstraint(1),
            ],
          );

      await notifier.loadLevel('level_multiple_quiz');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_multiple_quiz',
      );

      notifier.submitQuizAnswer({'a', 'b'});

      final solved = notifier.checkSolution();
      final state = container.read(levelStateProvider);

      expect(solved, isTrue);
      expect(state.status, LevelFlowStatus.challengeSolved);
      expect(state.currentSession!.status, SessionStatus.completed);
      expect(state.currentSession!.attemptsRemaining, 3);
    },
  );

  test(
    'checkSolution consumes attempt when multiple choice answer is partial',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_multiple_quiz'] = LevelSyllabus(
        id: 'level_multiple_quiz',
        title: 'Multiple Quiz Level',
        topic: LevelTopic.heaps,
        challenges: const ['quiz_heap_properties_multiple'],
        rewards: const LevelRewards(xp: 50, stars: 1),
      );

      contentRepository.specs['quiz_heap_properties_multiple'] =
          buildMultipleChoiceQuizSpec(
            constraints: const [
              MaxAttemptsConstraint(3),
              LivesConsumedOnFailConstraint(1),
            ],
          );

      await notifier.loadLevel('level_multiple_quiz');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_multiple_quiz',
      );

      notifier.submitQuizAnswer({'a'});

      final solved = notifier.checkSolution();
      final state = container.read(levelStateProvider);

      expect(solved, isFalse);
      expect(state.status, LevelFlowStatus.playing);
      expect(state.currentSession!.status, SessionStatus.inProgress);
      expect(state.currentSession!.attemptsRemaining, 2);
    },
  );

  test('startCurrentChallenge creates identify target runtime state', () async {
    final notifier = container.read(levelStateProvider.notifier);

    contentRepository.syllabuses['level_identify'] = LevelSyllabus(
      id: 'level_identify',
      title: 'Identify Level',
      topic: LevelTopic.heaps,
      challenges: const ['identify_heap_wrong_node'],
      rewards: const LevelRewards(xp: 50, stars: 1),
    );

    contentRepository.specs['identify_heap_wrong_node'] = buildIdentifyNodeSpec(
      constraints: const [
        MaxAttemptsConstraint(3),
        LivesConsumedOnFailConstraint(1),
      ],
    );

    await notifier.loadLevel('level_identify');

    await notifier.startCurrentChallenge(
      userId: 'user_1',
      sessionId: 'session_identify_1',
    );

    final state = container.read(levelStateProvider);

    expect(state.status, LevelFlowStatus.playing);
    expect(state.currentChallengeSpec!.id, 'identify_heap_wrong_node');
    expect(
      state.currentSession!.runtimeState,
      isA<IdentifyTargetRuntimeState>(),
    );
    expect(state.currentSession!.attemptsRemaining, 3);
  });

  test('submitIdentifyTarget stores selected target', () async {
    final notifier = container.read(levelStateProvider.notifier);

    contentRepository.syllabuses['level_identify'] = LevelSyllabus(
      id: 'level_identify',
      title: 'Identify Level',
      topic: LevelTopic.heaps,
      challenges: const ['identify_heap_wrong_node'],
      rewards: const LevelRewards(xp: 50, stars: 1),
    );

    contentRepository.specs['identify_heap_wrong_node'] = buildIdentifyNodeSpec(
      constraints: const [
        MaxAttemptsConstraint(3),
        LivesConsumedOnFailConstraint(1),
      ],
    );

    await notifier.loadLevel('level_identify');

    await notifier.startCurrentChallenge(
      userId: 'user_1',
      sessionId: 'session_identify_1',
    );

    notifier.submitIdentifyTarget({'n2'});

    final state = container.read(levelStateProvider);
    final runtimeState =
        state.currentSession!.runtimeState as IdentifyTargetRuntimeState;

    expect(runtimeState.selectedTargetIds, {'n2'});
    expect(runtimeState.submitted, isTrue);
    expect(state.status, LevelFlowStatus.playing);
  });

  test(
    'checkSolution marks identify target challenge as solved when target is correct',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_identify'] = LevelSyllabus(
        id: 'level_identify',
        title: 'Identify Level',
        topic: LevelTopic.heaps,
        challenges: const ['identify_heap_wrong_node'],
        rewards: const LevelRewards(xp: 50, stars: 1),
      );

      contentRepository.specs['identify_heap_wrong_node'] =
          buildIdentifyNodeSpec(
            constraints: const [
              MaxAttemptsConstraint(3),
              LivesConsumedOnFailConstraint(1),
            ],
          );

      await notifier.loadLevel('level_identify');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_identify_1',
      );

      notifier.submitIdentifyTarget({'n2'});

      final solved = notifier.checkSolution();
      final state = container.read(levelStateProvider);

      expect(solved, isTrue);
      expect(state.status, LevelFlowStatus.challengeSolved);
      expect(state.currentSession!.status, SessionStatus.completed);
      expect(state.currentSession!.attemptsRemaining, 3);
    },
  );

  test(
    'checkSolution consumes attempt when identify target is wrong',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_identify'] = LevelSyllabus(
        id: 'level_identify',
        title: 'Identify Level',
        topic: LevelTopic.heaps,
        challenges: const ['identify_heap_wrong_node'],
        rewards: const LevelRewards(xp: 50, stars: 1),
      );

      contentRepository.specs['identify_heap_wrong_node'] =
          buildIdentifyNodeSpec(
            constraints: const [
              MaxAttemptsConstraint(3),
              LivesConsumedOnFailConstraint(1),
            ],
          );

      await notifier.loadLevel('level_identify');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_identify_1',
      );

      notifier.submitIdentifyTarget({'n3'});

      final solved = notifier.checkSolution();
      final state = container.read(levelStateProvider);

      expect(solved, isFalse);
      expect(state.status, LevelFlowStatus.playing);
      expect(state.currentSession!.status, SessionStatus.inProgress);
      expect(state.currentSession!.attemptsRemaining, 2);
    },
  );

  test(
    'checkSolution marks identify target challenge as failed when wrong target consumes last attempt',
    () async {
      final notifier = container.read(levelStateProvider.notifier);

      contentRepository.syllabuses['level_identify'] = LevelSyllabus(
        id: 'level_identify',
        title: 'Identify Level',
        topic: LevelTopic.heaps,
        challenges: const ['identify_heap_wrong_node'],
        rewards: const LevelRewards(xp: 50, stars: 1),
      );

      contentRepository.specs['identify_heap_wrong_node'] =
          buildIdentifyNodeSpec(
            constraints: const [
              MaxAttemptsConstraint(1),
              LivesConsumedOnFailConstraint(1),
            ],
          );

      await notifier.loadLevel('level_identify');

      await notifier.startCurrentChallenge(
        userId: 'user_1',
        sessionId: 'session_identify_1',
      );

      notifier.submitIdentifyTarget({'n3'});

      final solved = notifier.checkSolution();
      final state = container.read(levelStateProvider);

      expect(solved, isFalse);
      expect(state.status, LevelFlowStatus.challengeFailed);
      expect(state.currentSession!.status, SessionStatus.failed);
      expect(state.currentSession!.attemptsRemaining, 0);
      expect(state.errorMessage, isNotNull);
    },
  );

  test('initial state has theory intro not seen', () {
    const state = LevelState.initial();

    expect(state.theoryIntroSeen, isFalse);
  });

  test('copyWith updates theoryIntroSeen', () {
    const state = LevelState.initial();

    final updated = state.copyWith(theoryIntroSeen: true);

    expect(updated.theoryIntroSeen, isTrue);
  });

  test('markTheoryIntroSeen sets theoryIntroSeen to true', () {
    final notifier = container.read(levelStateProvider.notifier);

    notifier.markTheoryIntroSeen();

    final state = container.read(levelStateProvider);

    expect(state.theoryIntroSeen, isTrue);
  });

  test('loadLevel resets theoryIntroSeen to false', () async {
    final notifier = container.read(levelStateProvider.notifier);

    notifier.markTheoryIntroSeen();
    expect(container.read(levelStateProvider).theoryIntroSeen, isTrue);

    await notifier.loadLevel('level_heap_intro');

    final state = container.read(levelStateProvider);

    expect(state.theoryIntroSeen, isFalse);
    expect(state.syllabus, isNotNull);
  });
}
