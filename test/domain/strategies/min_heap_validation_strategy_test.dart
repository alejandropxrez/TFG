import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/strategies/min_heap_validation_strategy.dart';

void main() {
  ChallengeSession buildSession(List<int> values) {
    final spec = ChallengeSpec(
      title: 'MinHeap',
      instruction: 'Fix heap',
      theoryRef: null,
      engineConfig: const ChallengeEngineConfig(
        validationStrategy: ValidationStrategyType.minHeap,
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

  test('returns true for a valid min heap', () {
    final strategy = MinHeapValidationStrategy();
    final session = buildSession([1, 3, 5, 7, 9]);

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false for an invalid min heap', () {
    final strategy = MinHeapValidationStrategy();
    final session = buildSession([10, 3, 5]);

    expect(strategy.isSolved(session), isFalse);
  });
}
