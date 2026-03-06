import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';

void main() {
  ChallengeSession buildSession(List<int> values) {
    final spec = ChallengeSpec(
      title: 'BST',
      instruction: 'Validate BST',
      theoryRef: null,
      engineConfig: const ChallengeEngineConfig(
        validationStrategy: ValidationStrategyType.bst,
        layoutStrategy: LayoutStrategyType.pyramid,
        connectionStrategy: ConnectionStrategyType.implicitHeap,
        interactionMode: InteractionModeType.swap,
        constraints: [],
      ),
      initialState: ChallengeInitialStateSpec(
        nodes: List.generate(
          values.length,
          (index) => ChallengeNodeSpec(id: 'n$index', value: values[index]),
        ),
        edges: const [],
        slots: const [],
      ),
    );

    return ChallengeSession.start(sessionId: 's1', userId: 'u1', spec: spec);
  }

  test('returns true for a valid BST stored as array tree', () {
    final strategy = BstValidationStrategy();
    final session = buildSession([8, 4, 12, 2, 6, 10, 14]);

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false for an invalid BST stored as array tree', () {
    final strategy = BstValidationStrategy();
    final session = buildSession([8, 10, 12]);

    expect(strategy.isSolved(session), isFalse);
  });
}
