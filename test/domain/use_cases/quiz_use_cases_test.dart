import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/quiz_action.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/usecases/check_quiz_answer_use_case.dart';
import 'package:algoquest/domain/usecases/submit_quiz_answer_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChallengeSpec buildSingleChoiceSpec() {
    return ChallengeSpec(
      id: 'quiz_1',
      title: 'Max heap question',
      instruction: 'Select the correct option',
      theoryRef: null,
      content: QuizChallengeContent(
        quizSpec: QuizSpec(
          question: 'Which property does a max heap satisfy?',
          options: [
            QuizOption(
              id: 'a',
              text: 'Every parent is greater than or equal to its children',
            ),
            QuizOption(id: 'b', text: 'Every child is greater than its parent'),
          ],
          correctOptionIds: {'a'},
        ),
      ),
    );
  }

  test(
    'ChallengeSession.start creates QuizRuntimeState for quiz challenge',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildSingleChoiceSpec(),
      );

      expect(session.runtimeState, isA<QuizRuntimeState>());

      final quizState = session.runtimeState as QuizRuntimeState;

      expect(quizState.selectedOptionIds, isEmpty);
      expect(quizState.submitted, isFalse);
      expect(session.status, SessionStatus.inProgress);
    },
  );

  test('SubmitQuizAnswerUseCase stores a valid single choice answer', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSingleChoiceSpec(),
    );

    const useCase = SubmitQuizAnswerUseCase();

    final updated = useCase(
      session: session,
      action: SubmitQuizAnswerAction.single('a'),
    );

    expect(updated.runtimeState, isA<QuizRuntimeState>());

    final quizState = updated.runtimeState as QuizRuntimeState;

    expect(quizState.selectedOptionIds, {'a'});
    expect(quizState.submitted, isTrue);
    expect(updated.status, SessionStatus.inProgress);
  });

  test('SubmitQuizAnswerUseCase ignores unknown option id', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSingleChoiceSpec(),
    );

    const useCase = SubmitQuizAnswerUseCase();

    final updated = useCase(
      session: session,
      action: SubmitQuizAnswerAction.single('missing'),
    );

    expect(identical(updated, session), isTrue);
  });

  test(
    'SubmitQuizAnswerUseCase ignores multiple answers in single choice quiz',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildSingleChoiceSpec(),
      );

      const useCase = SubmitQuizAnswerUseCase();

      final updated = useCase(
        session: session,
        action: const SubmitQuizAnswerAction(selectedOptionIds: {'a', 'b'}),
      );

      expect(identical(updated, session), isTrue);
    },
  );

  test(
    'CheckQuizAnswerUseCase marks session as completed when answer is correct',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildSingleChoiceSpec(),
      );

      final answered = const SubmitQuizAnswerUseCase()(
        session: session,
        action: SubmitQuizAnswerAction.single('a'),
      );

      final checked = const CheckQuizAnswerUseCase()(answered);

      expect(checked.status, SessionStatus.completed);
    },
  );

  test(
    'CheckQuizAnswerUseCase keeps session in progress when answer is incorrect',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildSingleChoiceSpec(),
      );

      final answered = const SubmitQuizAnswerUseCase()(
        session: session,
        action: SubmitQuizAnswerAction.single('b'),
      );

      final checked = const CheckQuizAnswerUseCase()(answered);

      expect(checked.status, SessionStatus.inProgress);
    },
  );

  test(
    'CheckQuizAnswerUseCase does not change session when answer was not submitted',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildSingleChoiceSpec(),
      );

      final checked = const CheckQuizAnswerUseCase()(session);

      expect(identical(checked, session), isTrue);
      expect(checked.status, SessionStatus.inProgress);
    },
  );
}
