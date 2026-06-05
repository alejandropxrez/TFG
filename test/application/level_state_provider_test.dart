import 'package:algoquest/application/app_providers.dart';
import 'package:algoquest/domain/usecases/load_user_progress_use_case.dart';
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

import 'package:algoquest/domain/usecases/check_solution_use_case.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/usecases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/usecases/manage_progress_use_case.dart';
import 'package:algoquest/domain/usecases/save_progress_use_case.dart';
import 'package:algoquest/domain/usecases/start_challenge_session_use_case.dart';

class AlwaysTrueValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => true;
}

class FakeContentRepository implements ContentRepository {
  final Map<String, LevelSyllabus> syllabuses = {};
  final Map<String, ChallengeSpec> specs = {};

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
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: AlwaysTrueValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        connectionType: ConnectionType.explicit,
        constraints: const [],
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
    );
  }

  setUp(() {
    contentRepository = FakeContentRepository();
    userRepository = FakeUserRepository();

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

    expect(state.currentSession!.currentState.nodes['n1']!.value, 3);
    expect(state.currentSession!.currentState.nodes['n2']!.value, 10);

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
    expect(session.movesUsed, 1);
    expect(session.history.length, 1);

    expect(session.currentState.nodes['n1']!.value, 10);
    expect(session.currentState.nodes['n2']!.value, 3);
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
}
