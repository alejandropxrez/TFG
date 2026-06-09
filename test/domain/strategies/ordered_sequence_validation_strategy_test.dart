import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/ordered_sequence_validation_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const strategy = OrderedSequenceValidationStrategy();

  ChallengeSession buildSession({
    required List<SlotState> slots,
    required List<NodeState> nodes,
  }) {
    final spec = ChallengeSpec(
      id: 'ordered_sequence',
      title: 'Ordena la secuencia',
      instruction: 'Ordena los valores',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.linkedList,
          validationStrategy: strategy,
          layoutStrategy: LayoutStrategyType.linear,
          interactionMode: InteractionModeType.drag,
          connectionType: ConnectionType.none,
        ),
        initialState: ChallengeInitialStateSpec(
          nodes: nodes
              .map((node) => ChallengeNodeSpec(id: node.id, value: node.value))
              .toList(growable: false),
          edges: const [],
          slots: slots
              .map((slot) => ChallengeSlotSpec(id: slot.id, index: slot.index))
              .toList(growable: false),
          inventory: const [],
        ),
      ),
    );

    final initialSession = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final state = StructureState.fromNodesAndEdges(
      type: StructureType.linkedList,
      nodes: nodes,
      edges: const [],
      slots: slots,
      inventory: const [],
    );

    return initialSession.copyWith(
      runtimeState: StructureRuntimeState(
        structure: state,
        history: const [],
        redoStack: const [],
        movesUsed: 0,
      ),
      status: SessionStatus.inProgress,
    );
  }

  test('returns true when filled slot values are ordered ascending', () {
    final session = buildSession(
      nodes: const [
        NodeState(id: 'n1', value: 3),
        NodeState(id: 'n2', value: 1),
        NodeState(id: 'n3', value: 2),
      ],
      slots: const [
        SlotState(id: 's1', index: 0, filledNodeId: 'n2'),
        SlotState(id: 's2', index: 1, filledNodeId: 'n3'),
        SlotState(id: 's3', index: 2, filledNodeId: 'n1'),
      ],
    );

    expect(strategy.isSolved(session), isTrue);
  });

  test('returns false when filled slot values are not ordered ascending', () {
    final session = buildSession(
      nodes: const [
        NodeState(id: 'n1', value: 3),
        NodeState(id: 'n2', value: 1),
        NodeState(id: 'n3', value: 2),
      ],
      slots: const [
        SlotState(id: 's1', index: 0, filledNodeId: 'n1'),
        SlotState(id: 's2', index: 1, filledNodeId: 'n2'),
        SlotState(id: 's3', index: 2, filledNodeId: 'n3'),
      ],
    );

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when any slot is empty', () {
    final session = buildSession(
      nodes: const [
        NodeState(id: 'n1', value: 1),
        NodeState(id: 'n2', value: 2),
      ],
      slots: const [
        SlotState(id: 's1', index: 0, filledNodeId: 'n1'),
        SlotState(id: 's2', index: 1),
      ],
    );

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when filled node does not exist', () {
    final session = buildSession(
      nodes: const [NodeState(id: 'n1', value: 1)],
      slots: const [SlotState(id: 's1', index: 0, filledNodeId: 'missing')],
    );

    expect(strategy.isSolved(session), isFalse);
  });

  test('returns false when filled node has null value', () {
    final session = buildSession(
      nodes: const [NodeState(id: 'n1', value: null)],
      slots: const [SlotState(id: 's1', index: 0, filledNodeId: 'n1')],
    );

    expect(strategy.isSolved(session), isFalse);
  });
}
