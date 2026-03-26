import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';

void main() {
  late ExecuteMoveUseCase useCase;

  setUp(() {
    useCase = const ExecuteMoveUseCase();
  });

  ChallengeSpec buildSpec({List<ChallengeConstraint> constraints = const []}) {
    return ChallengeSpec(
      title: 'Heap Repair',
      instruction: 'Swap nodes to fix the heap',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        constraints: constraints,
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [
          ChallengeNodeSpec(id: 'n1', value: 3),
          ChallengeNodeSpec(id: 'n2', value: 10),
        ],
        edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
        slots: [],
      ),
    );
  }

  test('applies valid SwapNodesAction and updates session metadata', () {
    final spec = buildSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(updated.movesUsed, 1);
    expect(updated.history.length, 1);
    expect(updated.status, SessionStatus.inProgress);
    expect(
      updated.updatedAt.isAfter(session.updatedAt) ||
          updated.updatedAt.isAtSameMomentAs(session.updatedAt),
      isTrue,
    );

    expect(updated.currentState.nodes['n1']!.value, 10);
    expect(updated.currentState.nodes['n2']!.value, 3);
  });

  test('does not change session when action is not applicable', () {
    final spec = buildSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(
        firstNodeId: 'n1',
        secondNodeId: 'unknown_node',
      ),
    );

    expect(updated.currentState.nodes['n1']!.value, 3);
    expect(updated.currentState.nodes['n2']!.value, 10);
    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
  });

  test('does not execute action when MaxMovesConstraint is reached', () {
    final spec = buildSpec(constraints: const [MaxMovesConstraint(0)]);

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.nodes['n1']!.value, 3);
    expect(updated.currentState.nodes['n2']!.value, 10);
  });

  test('does not execute SwapNodesAction on locked nodes', () {
    final spec = buildSpec(
      constraints: const [
        LockedNodesConstraint(['n1']),
      ],
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.nodes['n1']!.value, 3);
    expect(updated.currentState.nodes['n2']!.value, 10);
  });

  test('executes SetNodeValueAction on unlocked node', () {
    final spec = buildSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetNodeValueAction(nodeId: 'n1', value: 42),
    );

    expect(updated.movesUsed, 1);
    expect(updated.history.length, 1);
    expect(updated.currentState.nodes['n1']!.value, 42);
  });

  test('does not execute SetNodeValueAction on locked node', () {
    final spec = buildSpec(
      constraints: const [
        LockedNodesConstraint(['n1']),
      ],
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetNodeValueAction(nodeId: 'n1', value: 42),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.nodes['n1']!.value, 3);
  });
}
