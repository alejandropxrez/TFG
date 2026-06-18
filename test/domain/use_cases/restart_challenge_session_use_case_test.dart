import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/use_cases/restart_challenge_session_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final useCase = RestartChallengeSessionUseCase();

  ChallengeSpec buildQuizSpec() {
    return ChallengeSpec(
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
  }

  ChallengeSession buildSession({
    required ChallengeSpec spec,
    required int attemptsRemaining,
    SessionStatus status = SessionStatus.inProgress,
  }) {
    final now = DateTime(2026, 1, 1);

    return ChallengeSession(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
      runtimeState: const QuizRuntimeState(
        selectedOptionIds: {'a'},
        submitted: true,
      ),
      status: status,
      startedAt: now,
      updatedAt: now,
      attemptsRemaining: attemptsRemaining,
    );
  }

  group('RestartChallengeSessionUseCase', () {
    test('restarts runtime state and preserves remaining attempts', () {
      final spec = buildQuizSpec();

      final session = buildSession(
        spec: spec,
        attemptsRemaining: 2,
        status: SessionStatus.failed,
      );

      final restartedSession = useCase(session);
      final runtimeState = restartedSession.runtimeState as QuizRuntimeState;

      expect(restartedSession.sessionId, session.sessionId);
      expect(restartedSession.userId, session.userId);
      expect(restartedSession.spec, same(spec));
      expect(restartedSession.attemptsRemaining, 2);
      expect(restartedSession.status, SessionStatus.inProgress);

      expect(runtimeState.selectedOptionIds, isEmpty);
      expect(runtimeState.submitted, isFalse);
    });

    test('does nothing when no attempts remain', () {
      final spec = buildQuizSpec();

      final session = buildSession(
        spec: spec,
        attemptsRemaining: 0,
        status: SessionStatus.failed,
      );

      final restartedSession = useCase(session);

      expect(restartedSession, same(session));
    });
  });
}
