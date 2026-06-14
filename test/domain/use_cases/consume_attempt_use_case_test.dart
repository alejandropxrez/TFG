import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:algoquest/domain/use_cases/consume_attempt_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class AlwaysFalseValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => false;
}

void main() {
  ChallengeSpec buildSpec({List<ChallengeConstraint> constraints = const []}) {
    return ChallengeSpec(
      id: 'challenge_attempts',
      title: 'Attempts Challenge',
      instruction: 'Try it',
      theoryRef: null,
      constraints: constraints,
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: AlwaysFalseValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.swap,
          connectionType: ConnectionType.explicit,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [ChallengeNodeSpec(id: 'n1', value: 1)],
          edges: [],
          slots: [],
          inventory: [],
        ),
      ),
    );
  }

  test('does nothing when challenge has no max attempts', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(),
    );

    const useCase = ConsumeAttemptUseCase();

    final updated = useCase(session);

    expect(updated, same(session));
    expect(updated.attemptsRemaining, isNull);
    expect(updated.status, SessionStatus.inProgress);
  });

  test('decrements attempts by one when max attempts are present', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(constraints: const [MaxAttemptsConstraint(3)]),
    );

    const useCase = ConsumeAttemptUseCase();

    final updated = useCase(session);

    expect(updated.attemptsRemaining, 2);
    expect(updated.status, SessionStatus.inProgress);
  });

  test('ignores LivesConsumedOnFailConstraint when decrementing attempts', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(
        constraints: const [
          MaxAttemptsConstraint(5),
          LivesConsumedOnFailConstraint(2),
        ],
      ),
    );

    const useCase = ConsumeAttemptUseCase();

    final updated = useCase(session);

    expect(updated.attemptsRemaining, 4);
    expect(updated.status, SessionStatus.inProgress);
  });

  test('decrements attempts even when lives consumed on fail is zero', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(
        constraints: const [
          MaxAttemptsConstraint(3),
          LivesConsumedOnFailConstraint(0),
        ],
      ),
    );

    const useCase = ConsumeAttemptUseCase();

    final updated = useCase(session);

    expect(updated.attemptsRemaining, 2);
    expect(updated.status, SessionStatus.inProgress);
  });

  test('marks session as failed when last attempt is consumed', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(
        constraints: const [
          MaxAttemptsConstraint(1),
          LivesConsumedOnFailConstraint(1),
        ],
      ),
    );

    const useCase = ConsumeAttemptUseCase();

    final updated = useCase(session);

    expect(updated.attemptsRemaining, 0);
    expect(updated.status, SessionStatus.failed);
  });

  test('does not decrement attempts below zero', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(
        constraints: const [
          MaxAttemptsConstraint(1),
          LivesConsumedOnFailConstraint(5),
        ],
      ),
    );

    const useCase = ConsumeAttemptUseCase();

    final firstUpdate = useCase(session);
    final secondUpdate = useCase(firstUpdate);

    expect(firstUpdate.attemptsRemaining, 0);
    expect(firstUpdate.status, SessionStatus.failed);

    expect(secondUpdate.attemptsRemaining, 0);
    expect(secondUpdate.status, SessionStatus.failed);
  });
}
