import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/linked_list_validation_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChallengeSession buildSession({
    required List<ChallengeNodeSpec> nodes,
    required List<ChallengeEdgeSpec> edges,
  }) {
    final spec = ChallengeSpec(
      id: 'challenge_linked_list',
      title: 'Linked List',
      instruction: 'Build a valid linked list',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.linkedList,
          validationStrategy: LinkedListValidationStrategy(),
          layoutStrategy: LayoutStrategyType.linear,
          interactionMode: InteractionModeType.link,
          connectionType: ConnectionType.explicit,
        ),
        initialState: ChallengeInitialStateSpec(
          nodes: nodes,
          edges: edges,
          slots: const [],
          inventory: const [],
        ),
      ),
    );

    return ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );
  }

  test('returns true for valid linked list', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
        ChallengeNodeSpec(id: 'n3', value: 3),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n2', target: 'n3'),
      ],
    );

    expect(LinkedListValidationStrategy().isSolved(session), isTrue);
  });

  test('returns true for single node list', () {
    final session = buildSession(
      nodes: const [ChallengeNodeSpec(id: 'n1', value: 1)],
      edges: const [],
    );

    expect(LinkedListValidationStrategy().isSolved(session), isTrue);
  });

  test('returns false when node has two outgoing edges', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
        ChallengeNodeSpec(id: 'n3', value: 3),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
      ],
    );

    expect(LinkedListValidationStrategy().isSolved(session), isFalse);
  });

  test('returns false when node has two incoming edges', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
        ChallengeNodeSpec(id: 'n3', value: 3),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n3'),
        ChallengeEdgeSpec(source: 'n2', target: 'n3'),
      ],
    );

    expect(LinkedListValidationStrategy().isSolved(session), isFalse);
  });

  test('returns false when list has cycle', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
        ChallengeNodeSpec(id: 'n3', value: 3),
      ],
      edges: const [
        ChallengeEdgeSpec(source: 'n1', target: 'n2'),
        ChallengeEdgeSpec(source: 'n2', target: 'n3'),
        ChallengeEdgeSpec(source: 'n3', target: 'n1'),
      ],
    );

    expect(LinkedListValidationStrategy().isSolved(session), isFalse);
  });

  test('returns false when node is disconnected', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
        ChallengeNodeSpec(id: 'n3', value: 3),
      ],
      edges: const [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
    );

    expect(LinkedListValidationStrategy().isSolved(session), isFalse);
  });

  test('returns false when edge references missing node', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
      ],
      edges: const [ChallengeEdgeSpec(source: 'n1', target: 'missing')],
    );

    expect(LinkedListValidationStrategy().isSolved(session), isFalse);
  });
}
