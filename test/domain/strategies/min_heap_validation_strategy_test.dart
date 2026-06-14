import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/min_heap_validation_strategy.dart';

void main() {
  ChallengeSession buildSession({
    required List<ChallengeNodeSpec> nodes,
    required List<ChallengeEdgeSpec> edges,
  }) {
    final spec = ChallengeSpec(
      id: 'challenge_min_heap',
      title: 'Min Heap',
      instruction: 'Fix the heap',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: MinHeapValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.swap,
        ),
        initialState: ChallengeInitialStateSpec(
          nodes: nodes,
          edges: edges,
          slots: const [],
        ),
      ),
    );

    return ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );
  }

  test('returns true for a valid min heap', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 8),
        ChallengeNodeSpec(id: 'n4', value: 10),
        ChallengeNodeSpec(id: 'n5', value: 12),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
        ChallengeEdgeSpec(source: 'n2', target: 'n4'),
        ChallengeEdgeSpec(source: 'n2', target: 'n5'),
      ],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false when parent is greater than a child', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 10),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 8),
        ChallengeNodeSpec(id: 'n4', value: 12),
        ChallengeNodeSpec(id: 'n5', value: 15),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
        ChallengeEdgeSpec(source: 'n2', target: 'n4'),
        ChallengeEdgeSpec(source: 'n2', target: 'n5'),
      ],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns true for a single node heap', () {
    final session = buildSession(
      nodes: const [ChallengeNodeSpec(id: 'n1', value: 42)],
      edges: const [],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false when a node is disconnected', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 8),
      ],
      edges: const [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when structure has a cycle', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 8),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n2', target: 'n3'),
        ChallengeEdgeSpec(source: 'n3', target: 'n1'),
      ],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when a node has more than two children', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 3),
        ChallengeNodeSpec(id: 'n3', value: 4),
        ChallengeNodeSpec(id: 'n4', value: 5),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
        ChallengeEdgeSpec(source: 'n1', target: 'n4'),
      ],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when structure has multiple roots', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 2),
        ChallengeNodeSpec(id: 'n4', value: 6),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n3', target: 'n4'),
      ],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when a node has two parents', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
        ChallengeNodeSpec(id: 'n3', value: 8),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
        ChallengeEdgeSpec(source: 'n2', target: 'n3'),
      ],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when an edge references a missing node', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 5),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n2', target: 'missing'),
      ],
    );

    final strategy = MinHeapValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });
}
