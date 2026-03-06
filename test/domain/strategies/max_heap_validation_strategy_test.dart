import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';

void main() {
  ChallengeSession buildSession(List<int> values) {
    final spec = ChallengeSpec(
      title: 'MaxHeap',
      instruction: 'Fix heap',
      theoryRef: null,
      engineConfig: const ChallengeEngineConfig(
        validationStrategy: ValidationStrategyType.maxHeap,
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

  test('returns true for a valid max heap', () {
    final strategy = MaxHeapValidationStrategy();
    final session = buildSession([10, 5, 8, 2, 3]);

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false for an invalid max heap', () {
    final strategy = MaxHeapValidationStrategy();
    final session = buildSession([5, 10, 8]);

    expect(strategy.isSolved(session), isFalse);
  });
}
