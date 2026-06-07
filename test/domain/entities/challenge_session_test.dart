import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

class AlwaysTrueValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => true;
}

void main() {
  ChallengeSpec buildSpec({List<ChallengeConstraint> constraints = const []}) {
    return ChallengeSpec(
      id: 'challenge_attempts',
      title: 'Attempts Challenge',
      instruction: 'Try it',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: AlwaysTrueValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        connectionType: ConnectionType.explicit,
        constraints: constraints,
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [ChallengeNodeSpec(id: 'n1', value: 1)],
        edges: [],
        slots: [],
        inventory: [],
      ),
    );
  }

  test('initializes attemptsRemaining from MaxAttemptsConstraint', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(constraints: const [MaxAttemptsConstraint(3)]),
    );

    expect(session.attemptsRemaining, 3);
    expect(session.status, SessionStatus.inProgress);
  });

  test(
    'sets attemptsRemaining to null when MaxAttemptsConstraint is absent',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildSpec(),
      );

      expect(session.attemptsRemaining, isNull);
    },
  );

  test('copyWith updates attemptsRemaining', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(constraints: const [MaxAttemptsConstraint(3)]),
    );

    final updated = session.copyWith(attemptsRemaining: 2);

    expect(updated.attemptsRemaining, 2);
  });
}
