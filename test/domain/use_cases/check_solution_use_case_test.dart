import 'package:algoquest/domain/usecases/check_solution_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:algoquest/domain/strategies/validation_strategy_factory.dart';

class AlwaysTrueValidator implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => true;
}

class AlwaysFalseValidator implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => false;
}

class FakeValidationStrategyFactory implements ValidationStrategyFactory {
  final ValidationStrategy strategy;
  ValidationStrategyType? receivedType;

  FakeValidationStrategyFactory(this.strategy);

  @override
  ValidationStrategy create(ValidationStrategyType type) {
    receivedType = type;
    return strategy;
  }
}

void main() {
  ChallengeSpec buildSpec({required ValidationStrategyType validationType}) {
    return ChallengeSpec(
      title: 'Challenge',
      instruction: 'Solve it',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: validationType,
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        constraints: const [],
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [
          ChallengeNodeSpec(id: 'n1', value: 10),
          ChallengeNodeSpec(id: 'n2', value: 5),
        ],
        edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
        slots: [],
      ),
    );
  }

  test('returns true when strategy from factory reports solved', () {
    final spec = buildSpec(validationType: ValidationStrategyType.maxHeap);
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final factory = FakeValidationStrategyFactory(AlwaysTrueValidator());
    final useCase = CheckSolutionUseCase(factory);

    final result = useCase(session);

    expect(result, isTrue);
    expect(factory.receivedType, ValidationStrategyType.maxHeap);
  });

  test('returns false when strategy from factory reports not solved', () {
    final spec = buildSpec(validationType: ValidationStrategyType.bst);
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final factory = FakeValidationStrategyFactory(AlwaysFalseValidator());
    final useCase = CheckSolutionUseCase(factory);

    final result = useCase(session);

    expect(result, isFalse);
    expect(factory.receivedType, ValidationStrategyType.bst);
  });
}
