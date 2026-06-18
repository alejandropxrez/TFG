import 'package:algoquest/data/core/composition/use_cases.dart';
import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/learning_path_syllabus.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';
import 'package:algoquest/domain/strategies/expected_slot_values_validation_strategy.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/use_cases/check_challenge_use_case.dart';
import 'package:algoquest/domain/use_cases/check_solution_use_case.dart';
import 'package:algoquest/domain/use_cases/complete_level_use_case.dart';
import 'package:algoquest/domain/use_cases/consume_attempt_use_case.dart';
import 'package:algoquest/domain/use_cases/execute_move_use_case.dart';
import 'package:algoquest/domain/use_cases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/use_cases/get_next_level_id_use_case.dart';
import 'package:algoquest/domain/use_cases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/use_cases/load_learning_path_use_case.dart';
import 'package:algoquest/domain/use_cases/load_user_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/manage_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/redo_move_use_case.dart';
import 'package:algoquest/domain/use_cases/restart_challenge_session_use_case.dart';
import 'package:algoquest/domain/use_cases/reveal_challenge_answer_use_case.dart';
import 'package:algoquest/domain/use_cases/save_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/start_challenge_session_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_categorization_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_identify_target_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_quiz_answer_use_case.dart';
import 'package:algoquest/domain/use_cases/undo_move_use_case.dart';
import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/application_state/level_state_provider.dart';
import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_body_factory.dart';
import 'package:algoquest/presentation/widgets/challenge/components/binary_tree_swap_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/components/linked_list_slots_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/quiz_challenge_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeContentRepository implements ContentRepository {
  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) {
    throw UnimplementedError();
  }

  @override
  Future<LearningPathSyllabus> getSyllabus() {
    throw UnimplementedError();
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
  late UseCases useCases;

  setUp(() {
    final contentRepository = FakeContentRepository();
    final userRepository = FakeUserRepository();

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

  group('ChallengeBodyFactory', () {
    test(
      'builds LinkedListSlotsChallengeBody for linked-list linear drag challenges',
      () {
        final notifier = container.read(levelStateProvider.notifier);

        final body = ChallengeBodyFactory.build(
          spec: _linkedListDragSpec(),
          runtimeState: _linkedListRuntimeState(),
          game: AlgoQuestGame(),
          notifier: notifier,
        );

        expect(body, isA<LinkedListSlotsChallengeBody>());
      },
    );

    test(
      'linked-list body emits SetValueAction through real notifier flow',
      () {
        final notifier = container.read(levelStateProvider.notifier);
        final spec = _linkedListDragSpec();

        final session = ChallengeSession(
          sessionId: 'session_1',
          userId: 'user_1',
          spec: spec,
          runtimeState: _linkedListRuntimeState(),
          status: SessionStatus.inProgress,
          startedAt: DateTime(2026),
          updatedAt: DateTime(2026),
          attemptsRemaining: 3,
        );

        notifier.state = container
            .read(levelStateProvider)
            .copyWith(currentChallengeSpec: spec, currentSession: session);

        final body = ChallengeBodyFactory.build(
          spec: spec,
          runtimeState: session.runtimeState,
          game: AlgoQuestGame(),
          notifier: notifier,
        );

        expect(body, isA<LinkedListSlotsChallengeBody>());

        final linkedListBody = body as LinkedListSlotsChallengeBody;

        linkedListBody.onValueDropped(slotId: 's1', value: 2);

        final nextSession = container.read(levelStateProvider).currentSession;
        final runtimeState = nextSession?.runtimeState;

        expect(runtimeState, isA<StructureRuntimeState>());

        final structure = (runtimeState! as StructureRuntimeState).structure;

        expect(structure.slots['s1']?.filledNodeId, 'n2');
        expect(structure.inventory, [4]);
      },
    );

    test('linked-list body clears filled slot through real notifier flow', () {
      final notifier = container.read(levelStateProvider.notifier);
      final spec = _linkedListDragSpec();

      final session = ChallengeSession(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: spec,
        runtimeState: StructureRuntimeState(
          structure: StructureState.fromNodesAndEdges(
            type: StructureType.linkedList,
            nodes: const [
              NodeState(id: 'n2', value: 2),
              NodeState(id: 'n4', value: 4),
            ],
            edges: const [],
            slots: const [SlotState(id: 's1', index: 0, filledNodeId: 'n2')],
            inventory: const [4],
          ),
          movesUsed: 0,
          history: const [],
          redoStack: const [],
        ),
        status: SessionStatus.inProgress,
        startedAt: DateTime(2026),
        updatedAt: DateTime(2026),
        attemptsRemaining: 3,
      );

      notifier.state = container
          .read(levelStateProvider)
          .copyWith(currentChallengeSpec: spec, currentSession: session);

      final body = ChallengeBodyFactory.build(
        spec: spec,
        runtimeState: session.runtimeState,
        game: AlgoQuestGame(),
        notifier: notifier,
      );

      expect(body, isA<LinkedListSlotsChallengeBody>());

      final linkedListBody = body as LinkedListSlotsChallengeBody;

      linkedListBody.onSlotCleared?.call('s1');

      final nextSession = container.read(levelStateProvider).currentSession;
      final runtimeState = nextSession?.runtimeState;

      expect(runtimeState, isA<StructureRuntimeState>());

      final structure = (runtimeState! as StructureRuntimeState).structure;

      expect(structure.slots['s1']?.filledNodeId, isNull);
      expect(structure.inventory, contains(2));
      expect(structure.inventory, contains(4));
    });

    test(
      'builds BinaryTreeSwapChallengeBody for heap pyramid swap challenges',
      () {
        final notifier = container.read(levelStateProvider.notifier);

        final body = ChallengeBodyFactory.build(
          spec: _heapSwapSpec(),
          runtimeState: _heapRuntimeState(),
          game: AlgoQuestGame(),
          notifier: notifier,
        );

        expect(body, isA<BinaryTreeSwapChallengeBody>());
      },
    );

    test('quiz single selection replaces previous selected option', () {
      final notifier = container.read(levelStateProvider.notifier);
      final spec = _singleChoiceQuizSpec();

      final session = ChallengeSession(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: spec,
        runtimeState: const QuizRuntimeState(
          selectedOptionIds: {'binary_search_tree'},
        ),
        status: SessionStatus.inProgress,
        startedAt: DateTime(2026),
        updatedAt: DateTime(2026),
        attemptsRemaining: 3,
      );

      notifier.state = container
          .read(levelStateProvider)
          .copyWith(currentChallengeSpec: spec, currentSession: session);

      final body = ChallengeBodyFactory.build(
        spec: spec,
        runtimeState: session.runtimeState,
        game: AlgoQuestGame(),
        notifier: notifier,
      );

      expect(body, isA<QuizChallengeView>());

      final quizBody = body as QuizChallengeView;

      quizBody.onSelectOption('max_heap');

      final nextSession = container.read(levelStateProvider).currentSession;
      final runtimeState = nextSession?.runtimeState;

      expect(runtimeState, isA<QuizRuntimeState>());

      final quizRuntimeState = runtimeState! as QuizRuntimeState;

      expect(quizRuntimeState.selectedOptionIds, {'max_heap'});
    });

    test('quiz multiple selection toggles selected options', () {
      final notifier = container.read(levelStateProvider.notifier);
      final spec = _multipleChoiceQuizSpec();

      final session = ChallengeSession(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: spec,
        runtimeState: const QuizRuntimeState(
          selectedOptionIds: {'binary_search_tree'},
        ),
        status: SessionStatus.inProgress,
        startedAt: DateTime(2026),
        updatedAt: DateTime(2026),
        attemptsRemaining: 3,
      );

      notifier.state = container
          .read(levelStateProvider)
          .copyWith(currentChallengeSpec: spec, currentSession: session);

      final body = ChallengeBodyFactory.build(
        spec: spec,
        runtimeState: session.runtimeState,
        game: AlgoQuestGame(),
        notifier: notifier,
      );

      expect(body, isA<QuizChallengeView>());

      final quizBody = body as QuizChallengeView;

      quizBody.onSelectOption('max_heap');

      var nextSession = container.read(levelStateProvider).currentSession;
      var runtimeState = nextSession?.runtimeState;

      expect(runtimeState, isA<QuizRuntimeState>());
      expect((runtimeState! as QuizRuntimeState).selectedOptionIds, {
        'binary_search_tree',
        'max_heap',
      });

      final updatedBody =
          ChallengeBodyFactory.build(
                spec: spec,
                runtimeState: runtimeState,
                game: AlgoQuestGame(),
                notifier: notifier,
              )
              as QuizChallengeView;

      updatedBody.onSelectOption('binary_search_tree');

      nextSession = container.read(levelStateProvider).currentSession;
      runtimeState = nextSession?.runtimeState;

      expect(runtimeState, isA<QuizRuntimeState>());
      expect((runtimeState! as QuizRuntimeState).selectedOptionIds, {
        'max_heap',
      });
    });
  });
}

ChallengeSpec _linkedListDragSpec() {
  return ChallengeSpec(
    id: 'complete_value',
    title: 'Completa el valor',
    instruction: 'Arrastra el valor correcto al hueco',
    theoryRef: 'fill_missing_value',
    constraints: const [
      MaxAttemptsConstraint(3),
      LivesConsumedOnFailConstraint(1),
    ],
    content: StructureChallengeContent(
      engineConfig: const ChallengeEngineConfig(
        structureType: StructureType.linkedList,
        validationStrategy: ExpectedSlotValuesValidationStrategy(
          expectedValuesBySlotId: {'s1': 2},
        ),
        layoutStrategy: LayoutStrategyType.linear,
        interactionMode: InteractionModeType.drag,
      ),
      initialState: ChallengeInitialStateSpec(
        nodes: const [
          ChallengeNodeSpec(id: 'n2', value: 2),
          ChallengeNodeSpec(id: 'n4', value: 4),
        ],
        edges: const [],
        slots: const [ChallengeSlotSpec(id: 's1', index: 0)],
        inventory: const [2, 4],
      ),
    ),
  );
}

ChallengeSpec _heapSwapSpec() {
  return ChallengeSpec(
    id: 'repair_heap',
    title: 'Repara el heap',
    instruction:
        'Intercambia los nodos para restaurar la propiedad de Max-Heap',
    theoryRef: 'max_heap',
    constraints: const [MaxAttemptsConstraint(3)],
    content: StructureChallengeContent(
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
      ),
      initialState: ChallengeInitialStateSpec(
        nodes: const [
          ChallengeNodeSpec(id: 'n1', value: 10),
          ChallengeNodeSpec(id: 'n2', value: 20),
        ],
        edges: const [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
        slots: const [],
        inventory: const [],
      ),
    ),
  );
}

StructureRuntimeState _linkedListRuntimeState() {
  return StructureRuntimeState(
    structure: StructureState.fromNodesAndEdges(
      type: StructureType.linkedList,
      nodes: const [
        NodeState(id: 'n2', value: 2),
        NodeState(id: 'n4', value: 4),
      ],
      edges: const [],
      slots: const [SlotState(id: 's1', index: 0)],
      inventory: const [2, 4],
    ),
    movesUsed: 0,
    history: const [],
    redoStack: const [],
  );
}

StructureRuntimeState _heapRuntimeState() {
  return StructureRuntimeState(
    structure: StructureState.fromNodesAndEdges(
      type: StructureType.heap,
      nodes: const [
        NodeState(id: 'n1', value: 10),
        NodeState(id: 'n2', value: 20),
      ],
      edges: const [EdgeState(source: 'n1', target: 'n2')],
      slots: const [],
      inventory: const [],
    ),
    movesUsed: 0,
    history: const [],
    redoStack: const [],
  );
}

ChallengeSpec _singleChoiceQuizSpec() {
  return ChallengeSpec(
    id: 'quiz_single',
    title: 'Quiz single',
    instruction: 'Elige una respuesta',
    theoryRef: 'heap_intro',
    constraints: const [MaxAttemptsConstraint(3)],
    content: QuizChallengeContent(
      quizSpec: QuizSpec(
        question:
            'Which data structure always keeps the largest element at the root?',
        options: [
          QuizOption(id: 'binary_search_tree', text: 'Binary Search Tree'),
          QuizOption(id: 'linked_list', text: 'Linked List'),
          QuizOption(id: 'max_heap', text: 'Max Heap'),
        ],
        correctOptionIds: {'max_heap'},
        allowMultiple: false,
      ),
    ),
  );
}

ChallengeSpec _multipleChoiceQuizSpec() {
  return ChallengeSpec(
    id: 'quiz_multiple',
    title: 'Quiz multiple',
    instruction: 'Elige todas las respuestas correctas',
    theoryRef: 'tree_intro',
    constraints: const [MaxAttemptsConstraint(3)],
    content: QuizChallengeContent(
      quizSpec: QuizSpec(
        question: 'Select all tree-based structures.',
        options: [
          QuizOption(id: 'binary_search_tree', text: 'Binary Search Tree'),
          QuizOption(id: 'linked_list', text: 'Linked List'),
          QuizOption(id: 'max_heap', text: 'Max Heap'),
        ],
        correctOptionIds: {'binary_search_tree', 'max_heap'},
        allowMultiple: true,
      ),
    ),
  );
}
