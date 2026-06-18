import 'package:algoquest/domain/entities/categorize_spec.dart';
import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/use_cases/reveal_challenge_answer_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final useCase = RevealChallengeAnswerUseCase();

  ChallengeSession buildSession({
    required ChallengeSpec spec,
    required ChallengeRuntimeState runtimeState,
    required int attemptsRemaining,
    SessionStatus status = SessionStatus.failed,
  }) {
    final now = DateTime(2026, 1, 1);

    return ChallengeSession(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
      runtimeState: runtimeState,
      status: status,
      startedAt: now,
      updatedAt: now,
      attemptsRemaining: attemptsRemaining,
    );
  }

  group('RevealChallengeAnswerUseCase', () {
    test('reveals correct quiz options when no attempts remain', () {
      final spec = ChallengeSpec(
        id: 'quiz_1',
        title: 'Quiz',
        instruction: 'Selecciona la correcta',
        theoryRef: null,
        constraints: const [MaxAttemptsConstraint(3)],
        content: QuizChallengeContent(
          quizSpec: QuizSpec(
            question: 'Pregunta',
            options: const [
              QuizOption(id: 'a', text: 'A'),
              QuizOption(id: 'b', text: 'B'),
              QuizOption(id: 'c', text: 'C'),
            ],
            correctOptionIds: const {'b', 'c'},
            allowMultiple: true,
          ),
        ),
      );

      final session = buildSession(
        spec: spec,
        attemptsRemaining: 0,
        runtimeState: const QuizRuntimeState(selectedOptionIds: {'a'}),
      );

      final updatedSession = useCase(spec: spec, session: session);
      final runtimeState = updatedSession.runtimeState as QuizRuntimeState;

      expect(runtimeState.selectedOptionIds, {'b', 'c'});
      expect(runtimeState.submitted, isTrue);
      expect(updatedSession.attemptsRemaining, 0);
      expect(updatedSession.status, SessionStatus.failed);
      expect(updatedSession.spec, same(spec));
    });

    test('reveals correct identify targets when no attempts remain', () {
      final visualState = StructureState.fromNodesAndEdges(
        type: StructureType.heap,
        nodes: const [
          NodeState(id: 'root', value: 10),
          NodeState(id: 'left', value: 20),
          NodeState(id: 'right', value: 30),
        ],
        edges: const [
          EdgeState(source: 'root', target: 'left'),
          EdgeState(source: 'root', target: 'right'),
        ],
      );

      final spec = ChallengeSpec(
        id: 'identify_1',
        title: 'Identifica',
        instruction: 'Selecciona los objetivos',
        theoryRef: null,
        constraints: const [MaxAttemptsConstraint(3)],
        content: IdentifyTargetChallengeContent(
          identifySpec: IdentifyTargetSpec(
            prompt: 'Selecciona los objetivos correctos',
            targetType: IdentifyTargetType.node,
            correctTargetIds: {'left', 'right'},
            allowMultiple: true,
          ),
          visualStructure: StructureChallengeContent(
            engineConfig: ChallengeEngineConfig(
              structureType: StructureType.heap,
              validationStrategy: MaxHeapValidationStrategy(),
              layoutStrategy: LayoutStrategyType.pyramid,
              interactionMode: InteractionModeType.swap,
            ),
            initialState: const ChallengeInitialStateSpec(
              nodes: [
                ChallengeNodeSpec(id: 'root', value: 10),
                ChallengeNodeSpec(id: 'left', value: 20),
                ChallengeNodeSpec(id: 'right', value: 30),
              ],
              edges: [
                ChallengeEdgeSpec(source: 'root', target: 'left'),
                ChallengeEdgeSpec(source: 'root', target: 'right'),
              ],
              slots: [],
            ),
          ),
        ),
      );

      final session = buildSession(
        spec: spec,
        attemptsRemaining: 0,
        runtimeState: IdentifyTargetRuntimeState(
          visualState: visualState,
          selectedTargetIds: const {'root'},
        ),
      );

      final updatedSession = useCase(spec: spec, session: session);
      final runtimeState =
          updatedSession.runtimeState as IdentifyTargetRuntimeState;

      expect(runtimeState.selectedTargetIds, {'left', 'right'});
      expect(runtimeState.submitted, isTrue);
      expect(runtimeState.visualState, same(visualState));
      expect(updatedSession.attemptsRemaining, 0);
      expect(updatedSession.status, SessionStatus.failed);
    });

    test('reveals correct categorization when no attempts remain', () {
      final spec = ChallengeSpec(
        id: 'categorize_1',
        title: 'Categoriza',
        instruction: 'Clasifica los elementos',
        theoryRef: null,
        constraints: const [MaxAttemptsConstraint(3)],
        content: CategorizeChallengeContent(
          categorizeSpec: CategorizeSpec(
            prompt: 'Clasifica',
            categories: const [
              CategorizeCategory(id: 'constant', label: 'O(1)'),
              CategorizeCategory(id: 'linear', label: 'O(n)'),
            ],
            items: const [
              CategorizeItem(id: 'array_access', text: 'Acceso a array'),
              CategorizeItem(id: 'loop', text: 'Recorrer lista'),
            ],
            correctCategoryByItemId: const {
              'array_access': 'constant',
              'loop': 'linear',
            },
          ),
        ),
      );

      final session = buildSession(
        spec: spec,
        attemptsRemaining: 0,
        runtimeState: const CategorizeRuntimeState(
          selectedCategoryByItemId: {'array_access': 'linear'},
        ),
      );

      final updatedSession = useCase(spec: spec, session: session);
      final runtimeState =
          updatedSession.runtimeState as CategorizeRuntimeState;

      expect(runtimeState.selectedCategoryByItemId, {
        'array_access': 'constant',
        'loop': 'linear',
      });
      expect(updatedSession.attemptsRemaining, 0);
      expect(updatedSession.status, SessionStatus.failed);
    });

    test('does not reveal answer when attempts remain', () {
      final spec = ChallengeSpec(
        id: 'quiz_1',
        title: 'Quiz',
        instruction: 'Selecciona la correcta',
        theoryRef: null,
        constraints: const [MaxAttemptsConstraint(3)],
        content: QuizChallengeContent(
          quizSpec: QuizSpec(
            question: 'Pregunta',
            options: const [
              QuizOption(id: 'a', text: 'A'),
              QuizOption(id: 'b', text: 'B'),
            ],
            correctOptionIds: const {'b'},
            allowMultiple: false,
          ),
        ),
      );

      final session = buildSession(
        spec: spec,
        attemptsRemaining: 1,
        status: SessionStatus.inProgress,
        runtimeState: const QuizRuntimeState(selectedOptionIds: {'a'}),
      );

      final updatedSession = useCase(spec: spec, session: session);
      final runtimeState = updatedSession.runtimeState as QuizRuntimeState;

      expect(updatedSession, same(session));
      expect(runtimeState.selectedOptionIds, {'a'});
      expect(runtimeState.submitted, isFalse);
    });

    test('does nothing for structure challenges without explicit solution', () {
      final structure = StructureState.fromNodesAndEdges(
        type: StructureType.heap,
        nodes: const [
          NodeState(id: 'n1', value: 10),
          NodeState(id: 'n2', value: 20),
        ],
        edges: const [EdgeState(source: 'n1', target: 'n2')],
      );

      final spec = ChallengeSpec(
        id: 'heap_1',
        title: 'Heap',
        instruction: 'Ordena el heap',
        theoryRef: null,
        constraints: const [MaxAttemptsConstraint(3)],
        content: StructureChallengeContent(
          engineConfig: ChallengeEngineConfig(
            structureType: StructureType.heap,
            validationStrategy: MaxHeapValidationStrategy(),
            layoutStrategy: LayoutStrategyType.pyramid,
            interactionMode: InteractionModeType.swap,
          ),
          initialState: const ChallengeInitialStateSpec(
            nodes: [
              ChallengeNodeSpec(id: 'n1', value: 10),
              ChallengeNodeSpec(id: 'n2', value: 20),
            ],
            edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
            slots: [],
          ),
        ),
      );

      final session = buildSession(
        spec: spec,
        attemptsRemaining: 0,
        runtimeState: StructureRuntimeState(structure: structure),
      );

      final updatedSession = useCase(spec: spec, session: session);

      expect(updatedSession, same(session));
    });
  });
}
