import 'package:algoquest/domain/entities/categorize_spec.dart';
import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/use_cases/submit_categorization_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const useCase = SubmitCategorizationUseCase();

  CategorizeSpec categorizeSpec() {
    return const CategorizeSpec(
      prompt: 'Clasifica cada operación',
      categories: [
        CategorizeCategory(id: 'o1', label: 'O(1)'),
        CategorizeCategory(id: 'on', label: 'O(n)'),
      ],
      items: [
        CategorizeItem(
          id: 'array_access',
          text: 'Acceder a un array por índice',
        ),
        CategorizeItem(
          id: 'linear_search',
          text: 'Buscar secuencialmente en una lista',
        ),
      ],
      correctCategoryByItemId: {'array_access': 'o1', 'linear_search': 'on'},
    );
  }

  ChallengeSession categorizeSession({
    Map<String, String> selectedCategoryByItemId = const {},
  }) {
    final spec = ChallengeSpec(
      id: 'categorize_complexity',
      title: 'Clasifica las operaciones',
      instruction: 'Asigna cada operación a su complejidad',
      theoryRef: null,
      constraints: const [],
      content: CategorizeChallengeContent(categorizeSpec: categorizeSpec()),
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

  ChallengeSession quizSession() {
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

  group('SubmitCategorizationUseCase', () {
    test('stores selected category for item', () {
      final session = categorizeSession();

      final updated = useCase(
        session: session,
        itemId: 'array_access',
        categoryId: 'o1',
      );

      final runtimeState = updated.runtimeState as CategorizeRuntimeState;

      expect(runtimeState.selectedCategoryByItemId, {'array_access': 'o1'});
      expect(updated.status, SessionStatus.inProgress);
    });

    test('replaces selected category for same item', () {
      final session = categorizeSession(
        selectedCategoryByItemId: const {'array_access': 'on'},
      );

      final updated = useCase(
        session: session,
        itemId: 'array_access',
        categoryId: 'o1',
      );

      final runtimeState = updated.runtimeState as CategorizeRuntimeState;

      expect(runtimeState.selectedCategoryByItemId, {'array_access': 'o1'});
      expect(updated.status, SessionStatus.inProgress);
    });

    test('returns same session when runtime state is not categorize', () {
      final session = quizSession();

      final updated = useCase(
        session: session,
        itemId: 'array_access',
        categoryId: 'o1',
      );

      expect(identical(updated, session), isTrue);
    });
  });

  test('returns unchanged session when item id is unknown', () {
    const useCase = SubmitCategorizationUseCase();

    final session = categorizeSession();

    final updated = useCase(
      session: session,
      itemId: 'unknown_item',
      categoryId: 'constant',
    );

    expect(updated, same(session));
    expect(
      (updated.runtimeState as CategorizeRuntimeState).selectedCategoryByItemId,
      isEmpty,
    );
  });

  test('returns unchanged session when category id is unknown', () {
    const useCase = SubmitCategorizationUseCase();

    final session = categorizeSession();

    final updated = useCase(
      session: session,
      itemId: 'array_access',
      categoryId: 'unknown_category',
    );

    expect(updated, same(session));
    expect(
      (updated.runtimeState as CategorizeRuntimeState).selectedCategoryByItemId,
      isEmpty,
    );
  });
}
