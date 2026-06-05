import 'package:algoquest/domain/entities/structure_state.dart';
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

  ChallengeSpec buildSwapSpec({
    List<ChallengeConstraint> constraints = const [],
    InteractionModeType interactionMode = InteractionModeType.swap,
  }) {
    return ChallengeSpec(
      id: 'challenge_1',
      title: 'Heap Repair',
      instruction: 'Swap nodes to fix the heap',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: interactionMode,
        constraints: constraints,
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [
          ChallengeNodeSpec(id: 'n1', value: 3),
          ChallengeNodeSpec(id: 'n2', value: 10),
        ],
        edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
        slots: [],
        inventory: [],
      ),
    );
  }

  ChallengeSpec buildSetValueSpec({
    List<ChallengeConstraint> constraints = const [],
  }) {
    return ChallengeSpec(
      id: 'challenge_1',
      title: 'Fill blank',
      instruction: 'Assign a value to the empty slot',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.setValue,
        constraints: constraints,
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [ChallengeNodeSpec(id: 'n1', value: 10)],
        edges: [],
        slots: [ChallengeSlotSpec(id: 's1', index: 0)],
        inventory: [42],
      ),
    );
  }

  test('applies valid SwapNodesAction and updates session metadata', () {
    final spec = buildSwapSpec();

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
    final spec = buildSwapSpec();

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
    final spec = buildSwapSpec(constraints: const [MaxMovesConstraint(0)]);

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
    final spec = buildSwapSpec(
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

  test('executes SetValueAction on unlocked slot', () {
    final spec = buildSetValueSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.movesUsed, 1);
    expect(updated.history.length, 1);
    expect(updated.currentState.slots['s1']!.filledNodeId, isNotNull);
    expect(updated.currentState.inventory.contains(42), isFalse);

    final createdNodeId = updated.currentState.slots['s1']!.filledNodeId!;
    expect(updated.currentState.nodes[createdNodeId]!.value, 42);
  });

  test('does not execute SetValueAction on locked slot', () {
    final spec = buildSetValueSpec(
      constraints: const [
        LockedNodesConstraint(['s1']),
      ],
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.slots['s1']!.filledNodeId, isNull);
    expect(updated.currentState.inventory.contains(42), isTrue);
  });

  test('does not execute SetValueAction if slot is already filled', () {
    final spec = ChallengeSpec(
      id: 'challenge_1',
      title: 'Filled slot',
      instruction: 'Cannot overwrite slot',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.setValue,
        constraints: const [],
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [ChallengeNodeSpec(id: 'n1', value: 10)],
        edges: [],
        slots: [ChallengeSlotSpec(id: 's1', index: 0)],
        inventory: [42],
      ),
    );

    final initialSession = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final session = initialSession.copyWith(
      currentState: initialSession.currentState.copyWith(
        slots: {'s1': const SlotState(id: 's1', index: 0, filledNodeId: 'n1')},
      ),
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.slots['s1']!.filledNodeId, 'n1');
    expect(updated.currentState.inventory.contains(42), isTrue);
  });

  test('does not execute SetValueAction if value is not in inventory', () {
    final spec = ChallengeSpec(
      id: 'challenge_1',
      title: 'Wrong inventory',
      instruction: 'Value missing from inventory',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: MaxHeapValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.setValue,
        constraints: const [],
      ),
      initialState: const ChallengeInitialStateSpec(
        nodes: [ChallengeNodeSpec(id: 'n1', value: 10)],
        edges: [],
        slots: [ChallengeSlotSpec(id: 's1', index: 0)],
        inventory: [7],
      ),
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.slots['s1']!.filledNodeId, isNull);
    expect(updated.currentState.inventory, [7]);
  });

  test('does not execute SetValueAction in swap interaction mode', () {
    final spec = buildSwapSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 'n1', value: 42),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.nodes['n1']!.value, 3);
    expect(updated.currentState.nodes['n2']!.value, 10);
  });

  test('does not execute SwapNodesAction in setValue interaction mode', () {
    final spec = buildSetValueSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 's1'),
    );

    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
    expect(updated.currentState.nodes['n1']!.value, 10);
    expect(updated.currentState.slots['s1']!.filledNodeId, isNull);
    expect(updated.currentState.inventory, [42]);
  });

  test('does not execute SwapNodesAction in drag interaction mode', () {
    final spec = buildSwapSpec(interactionMode: InteractionModeType.drag);

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
}
