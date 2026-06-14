import 'package:algoquest/domain/entities/categorize_spec.dart';
import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/use_cases/check_categorization_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const useCase = CheckCategorizationUseCase();

  group('CheckCategorizationUseCase', () {
    test('marks session as completed when all categorizations are correct', () {
      final session = _session(
        selectedCategoryByItemId: const {
          'array_access': 'o1',
          'linear_search': 'on',
        },
      );

      final updated = useCase(session);

      expect(updated.status, SessionStatus.completed);
    });

    test('keeps session in progress when one category is wrong', () {
      final session = _session(
        selectedCategoryByItemId: const {
          'array_access': 'on',
          'linear_search': 'on',
        },
      );

      final updated = useCase(session);

      expect(updated.status, SessionStatus.inProgress);
    });

    test('keeps session in progress when an item is missing', () {
      final session = _session(
        selectedCategoryByItemId: const {'array_access': 'o1'},
      );

      final updated = useCase(session);

      expect(updated.status, SessionStatus.inProgress);
    });

    test('returns same session when content is not categorize', () {
      final session = _nonCategorizeSession();

      final updated = useCase(session);

      expect(identical(updated, session), isTrue);
    });
  });
}

ChallengeSession _session({
  required Map<String, String> selectedCategoryByItemId,
}) {
  final spec = ChallengeSpec(
    id: 'categorize_complexity',
    title: 'Clasifica las operaciones',
    instruction: 'Asigna cada operación a su complejidad',
    theoryRef: null,
    constraints: const [],
    content: CategorizeChallengeContent(categorizeSpec: _categorizeSpec()),
  );

  return ChallengeSession(
    sessionId: 'session_1',
    userId: 'user_1',
    spec: spec,
    runtimeState: CategorizeRuntimeState(
      selectedCategoryByItemId: selectedCategoryByItemId,
    ),
    status: SessionStatus.inProgress,
    startedAt: DateTime(2024),
    updatedAt: DateTime(2024),
    attemptsRemaining: null,
  );
}

ChallengeSession _nonCategorizeSession() {
  final spec = ChallengeSpec(
    id: 'quiz_1',
    title: 'Quiz',
    instruction: 'Selecciona',
    theoryRef: null,
    constraints: const [],
    content: QuizChallengeContent(
      quizSpec: QuizSpec(
        question: 'Pregunta',
        options: const [
          QuizOption(id: 'a', text: 'A'),
          QuizOption(id: 'b', text: 'B'),
        ],
        correctOptionIds: const {'a'},
        allowMultiple: false,
      ),
    ),
  );

  return ChallengeSession(
    sessionId: 'session_1',
    userId: 'user_1',
    spec: spec,
    runtimeState: const QuizRuntimeState(),
    status: SessionStatus.inProgress,
    startedAt: DateTime(2024),
    updatedAt: DateTime(2024),
    attemptsRemaining: null,
  );
}

CategorizeSpec _categorizeSpec() {
  return const CategorizeSpec(
    prompt: 'Clasifica cada operación',
    categories: [
      CategorizeCategory(id: 'o1', label: 'O(1)'),
      CategorizeCategory(id: 'on', label: 'O(n)'),
    ],
    items: [
      CategorizeItem(id: 'array_access', text: 'Acceder a un array por índice'),
      CategorizeItem(
        id: 'linear_search',
        text: 'Buscar secuencialmente en una lista',
      ),
    ],
    correctCategoryByItemId: {'array_access': 'o1', 'linear_search': 'on'},
  );
}
