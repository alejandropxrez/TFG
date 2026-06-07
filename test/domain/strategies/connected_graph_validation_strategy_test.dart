import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/connected_graph_validation_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChallengeSession buildSession({
    required List<ChallengeNodeSpec> nodes,
    required List<ChallengeEdgeSpec> edges,
  }) {
    final spec = ChallengeSpec(
      id: 'challenge_connected_graph',
      title: 'Connected Graph',
      instruction: 'Connect all nodes',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.graph,
          validationStrategy: ConnectedGraphValidationStrategy(),
          layoutStrategy: LayoutStrategyType.circular,
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

  test('returns true for connected graph', () {
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

    expect(ConnectedGraphValidationStrategy().isSolved(session), isTrue);
  });

  test('returns false when graph has isolated node', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
        ChallengeNodeSpec(id: 'n3', value: 3),
      ],
      edges: const [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
    );

    expect(ConnectedGraphValidationStrategy().isSolved(session), isFalse);
  });

  test('returns false for empty graph', () {
    final session = buildSession(nodes: const [], edges: const []);

    expect(ConnectedGraphValidationStrategy().isSolved(session), isFalse);
  });

  test('returns true for single node graph', () {
    final session = buildSession(
      nodes: const [ChallengeNodeSpec(id: 'n1', value: 1)],
      edges: const [],
    );

    expect(ConnectedGraphValidationStrategy().isSolved(session), isTrue);
  });

  test('returns false when edge references missing node', () {
    final session = buildSession(
      nodes: const [
        ChallengeNodeSpec(id: 'n1', value: 1),
        ChallengeNodeSpec(id: 'n2', value: 2),
      ],
      edges: const [ChallengeEdgeSpec(source: 'n1', target: 'missing')],
    );

    expect(ConnectedGraphValidationStrategy().isSolved(session), isFalse);
  });
}
