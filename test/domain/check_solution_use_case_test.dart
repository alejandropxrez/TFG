import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:algoquest/domain/usecases/check_solution_use_case.dart';

class AlwaysTrueValidator implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => true;
}

class AlwaysFalseValidator implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => false;
}

void main() {
  const spec = ChallengeSpec(
    title: 't',
    instruction: 'i',
    theoryRef: null,
    engineConfig: ChallengeEngineConfig(
      validationStrategy: ValidationStrategyType.maxHeap,
      layoutStrategy: LayoutStrategyType.pyramid,
      connectionStrategy: ConnectionStrategyType.implicitHeap,
      interactionMode: InteractionModeType.swap,
      constraints: [],
    ),
    initialState: ChallengeInitialStateSpec(nodes: [], edges: [], slots: []),
  );

  test('returns true when validator reports solved', () {
    final session = ChallengeSession.start(
      sessionId: 's',
      userId: 'u',
      spec: spec,
    );

    final useCase = CheckSolutionUseCase(AlwaysTrueValidator());
    expect(useCase(session), isTrue);
  });

  test('returns false when validator reports not solved', () {
    final session = ChallengeSession.start(
      sessionId: 's',
      userId: 'u',
      spec: spec,
    );

    final useCase = CheckSolutionUseCase(AlwaysFalseValidator());
    expect(useCase(session), isFalse);
  });
}
