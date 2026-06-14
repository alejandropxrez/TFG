import 'package:algoquest/domain/use_cases/check_solution_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

class AlwaysTrueValidator implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => true;
}

class AlwaysFalseValidator implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => false;
}

void main() {
  ChallengeSpec buildSpec({required ValidationStrategy validationStrategy}) {
    return ChallengeSpec(
      id: 'challenge_1',
      title: 'Challenge',
      instruction: 'Solve it',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: validationStrategy,
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.swap,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [
            ChallengeNodeSpec(id: 'n1', value: 10),
            ChallengeNodeSpec(id: 'n2', value: 5),
          ],
          edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
          slots: [],
        ),
      ),
    );
  }

  test('returns true when challenge validation strategy reports solved', () {
    final spec = buildSpec(validationStrategy: AlwaysTrueValidator());

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    const useCase = CheckSolutionUseCase();

    final result = useCase(session);

    expect(result, isTrue);
  });

  test(
    'returns false when challenge validation strategy reports not solved',
    () {
      final spec = buildSpec(validationStrategy: AlwaysFalseValidator());

      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: spec,
      );

      const useCase = CheckSolutionUseCase();

      final result = useCase(session);

      expect(result, isFalse);
    },
  );
}
