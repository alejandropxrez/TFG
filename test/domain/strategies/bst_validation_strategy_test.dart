import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';

void main() {
  ChallengeSession buildSession({
    required List<ChallengeNodeSpec> nodes,
    required List<ChallengeEdgeSpec> edges,
  }) {
    final spec = ChallengeSpec(
      title: 'BST',
      instruction: 'Validate BST',
      theoryRef: null,
      engineConfig: const ChallengeEngineConfig(
        structureType: StructureType.bst,
        validationStrategy: ValidationStrategyType.bst,
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        constraints: [],
      ),
      initialState: ChallengeInitialStateSpec(
        nodes: nodes,
        edges: edges,
        slots: const [],
      ),
    );

    return ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );
  }

  test('returns true for a valid BST', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 10),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 15),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'), // left
        ChallengeEdgeSpec(source: 'n1', target: 'n3'), // right
      ],
    );

    final strategy = BstValidationStrategy();

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false when left child is greater than parent', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 10),
        ChallengeNodeSpec(id: 'n2', value: 20), // ❌ wrong
        ChallengeNodeSpec(id: 'n3', value: 15),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
      ],
    );

    final strategy = BstValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when right child is smaller than parent', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 10),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 7), // ❌ wrong
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
      ],
    );

    final strategy = BstValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns true for single node BST', () {
    final session = buildSession(
      nodes: const [ChallengeNodeSpec(id: 'n1', value: 42)],
      edges: const [],
    );

    final strategy = BstValidationStrategy();

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false for deeper invalid BST (violates subtree rule)', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 10),
        ChallengeNodeSpec(id: 'n2', value: 5),
        ChallengeNodeSpec(id: 'n3', value: 15),
        ChallengeNodeSpec(id: 'n4', value: 12), // ❌ debería estar > 10
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
        ChallengeEdgeSpec(source: 'n2', target: 'n4'), // mal colocado
      ],
    );

    final strategy = BstValidationStrategy();

    expect(strategy.isSolved(session), isFalse);
  });
}
