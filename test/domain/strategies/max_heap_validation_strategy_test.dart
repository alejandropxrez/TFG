import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';

void main() {
  ChallengeSession buildSession(List<ChallengeNodeSpec> nodes) {
    final spec = ChallengeSpec(
      id: 'challenge_max_heap',
      title: 'Max Heap',
      instruction: 'Fix the heap',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        constraints: [],
      ),
      initialState: ChallengeInitialStateSpec(
        nodes: nodes,
        edges: const [
          ChallengeEdgeSpec(source: 'n1', target: 'n2'),
          ChallengeEdgeSpec(source: 'n1', target: 'n3'),
          ChallengeEdgeSpec(source: 'n2', target: 'n4'),
          ChallengeEdgeSpec(source: 'n2', target: 'n5'),
        ],
        slots: const [],
      ),
    );

    return ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );
  }

  test('returns true for a valid max heap', () {
    final session = buildSession(const [
      ChallengeNodeSpec(id: 'n1', value: 10),
      ChallengeNodeSpec(id: 'n2', value: 5),
      ChallengeNodeSpec(id: 'n3', value: 8),
      ChallengeNodeSpec(id: 'n4', value: 2),
      ChallengeNodeSpec(id: 'n5', value: 3),
    ]);

    final strategy = MaxHeapValidationStrategy();

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false when parent is smaller than a child', () {
    final session = buildSession(const [
      ChallengeNodeSpec(id: 'n1', value: 5),
      ChallengeNodeSpec(id: 'n2', value: 10),
      ChallengeNodeSpec(id: 'n3', value: 8),
      ChallengeNodeSpec(id: 'n4', value: 2),
      ChallengeNodeSpec(id: 'n5', value: 3),
    ]);

    final strategy = MaxHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns true for a single node heap', () {
    final spec = ChallengeSpec(
      id: 'challenge_single_node_heap',
      title: 'Single Node Heap',
      instruction: 'Check heap',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        constraints: [],
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [ChallengeNodeSpec(id: 'n1', value: 42)],
        edges: [],
        slots: [],
      ),
    );

    final session = ChallengeSession.start(
      sessionId: 'session_2',
      userId: 'user_1',
      spec: spec,
    );

    final strategy = MaxHeapValidationStrategy();

    expect(strategy.isSolved(session), isTrue);
  });
}
